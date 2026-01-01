use futures_util::StreamExt;
use lapin::{Connection, ConnectionProperties, options::*, types::FieldTable};
use std::sync::Arc;
use std::{fs, path::Path};
use tokio::{sync::Semaphore, task};

use crate::engine::transforms::Transform;
use crate::rabbit::UploadDto;

pub struct Dispatcher {
    host: String,
    queue: String,
    upload_dir: String,
}

impl Dispatcher {
    pub fn new() -> Self {
        let rabbitmq_host = std::env::var("RABBITMQ_HOST").expect("env wasn't set");
        let transform_queue = std::env::var("TRANSFORM_QUEUE").expect("env wasn't set");
        let upload_dir = std::env::var("UPLOAD_DIR").expect("env wasn't set");
        Dispatcher {
            host: rabbitmq_host,
            queue: transform_queue,
            upload_dir: upload_dir,
        }
    }

    pub async fn consume(self: Arc<Self>) -> Result<(), ()> {
        let conn = Connection::connect(&self.host, ConnectionProperties::default())
            .await
            .expect("connection error");

        let channel = conn.create_channel().await.expect("create_channel");

        channel
            .basic_qos(16, BasicQosOptions::default())
            .await
            .expect("basic_qos");

        let mut consumer = channel
            .basic_consume(
                &self.queue,
                "image_service",
                BasicConsumeOptions::default(),
                FieldTable::default(),
            )
            .await
            .expect("basic_consume");

        let semaphore = Arc::new(Semaphore::new(16));

        while let Some(delivery) = consumer.next().await {
            let delivery = match delivery {
                Ok(d) => d,
                Err(e) => {
                    tracing::error!("consumer error: {e}");
                    continue;
                }
            };

            let permit = match semaphore.clone().acquire_owned().await {
                Ok(p) => p,
                Err(e) => {
                    tracing::error!("failed to acquire semaphore: {e}");
                    break;
                }
            };

            let dispatcher = Arc::clone(&self);

            task::spawn(async move {
                let result = dispatcher.handle_message(delivery.data.clone()).await;

                match result {
                    Ok(_) => {
                        let _ = delivery.ack(BasicAckOptions::default()).await;
                    }
                    Err(e) => {
                        let _ = delivery.nack(BasicNackOptions::default()).await;
                        eprintln!("Consumer error: {:?}", e);
                    }
                }

                drop(permit);
            });
        }

        Ok(())
    }

    async fn handle_message(&self, data: Vec<u8>) -> Result<(), serde_json::Error> {
        let upload = serde_json::from_slice::<UploadDto>(&data)?;
        println!("got file: {:?}", upload);
        let batch_dir = Path::join(Path::new(&self.upload_dir), upload.id.to_string());
        for f in fs::read_dir(batch_dir).unwrap() {
            match f {
                Ok(name) => if !name.path().ends_with(Path::new(".json")) {
                    let _ = Transform::apply_raw(name.path().clone(),upload.id.to_string(),&upload.transform);
                },
                Err(e) => {
                    eprintln!("Unable to transform error: {:?}", e);
                }
            }
        }

        Ok(())
    }
}
