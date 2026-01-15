use anyhow::Result;
use futures_util::StreamExt;
use lapin::{Connection, ConnectionProperties, options::*, types::FieldTable};
use std::sync::Arc;
use tokio::{sync::Semaphore, task};

use crate::application::{LocalStorage, TransformEngine};
use crate::domain::{Storage, constants};
use crate::domain::UploadDto;

pub struct Dispatcher {
    host: String,
    queue: String,
}

impl Dispatcher {
    pub fn new() -> Self {
        let host = dotenv::var(constants::RABBITMQ_HOST).unwrap();
        let queue = dotenv::var(constants::TRANSFORM_QUEUE).unwrap();
        Self { host, queue }
    }

    pub async fn start(&self) -> Result<()> {
        println!(
            "Dispatcher started at : {} and queue : {}",
            self.host.clone(),
            self.queue.clone()
        );

        let conn = Connection::connect(&self.host, ConnectionProperties::default()).await?;

        let channel = conn.create_channel().await?;

        channel.basic_qos(16, BasicQosOptions::default()).await?;

        let storage: Arc<dyn Storage> = Arc::new(LocalStorage::new());
        let service = Arc::new(TransformEngine::new(storage));

        let mut consumer = channel
            .basic_consume(
                &self.queue,
                "image_service",
                BasicConsumeOptions::default(),
                FieldTable::default(),
            )
            .await?;

        // let semaphore = Arc::new(Semaphore::new(16));

        while let Some(delivery) = consumer.next().await {
            let delivery = delivery?;
            let srv = Arc::clone(&service);
            // let permit = semaphore.clone().acquire_owned().await?;
            let msg: Result<UploadDto, serde_json::Error> = serde_json::from_slice(&delivery.data);
            match msg {
                Ok(dto) => {
                    // task::spawn(async move  {
                        let result = srv.handle(dto.to_map());

                        match result {
                            Ok(_) => {
                                let _ = delivery.ack(BasicAckOptions::default()).await;
                            }
                            Err(e) => {
                                let _ = delivery.nack(BasicNackOptions::default()).await;
                                tracing::error!("message failed: {e:?}");
                            }
                        }

                        // drop(permit);
                }
                Err(e) => {eprintln!("error deserializing the dto: {}",e);continue},
            }
        }

        Ok(())
    }
}
