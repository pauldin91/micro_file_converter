use anyhow::Result;
use anyhow::anyhow;
use futures_util::StreamExt;
use lapin::{Connection, ConnectionProperties, options::*, types::FieldTable};
use std::sync::Arc;
use tokio::{sync::Semaphore, task};
use tracing::{error, info};

use crate::domain::Publisher;
use crate::domain::UploadDto;
use crate::domain::{Storage, config};
use crate::infrastructure::RabbitMqPublisher;
use crate::infrastructure::{LocalStorage, TransformEngine};

pub struct Dispatcher {
    host: String,
    queue: String,
    permits: usize,
}

impl Dispatcher {
    pub fn new() -> Self {
        let host = dotenv::var(config::RABBITMQ_HOST).unwrap();
        let queue = dotenv::var(config::TRANSFORM_QUEUE).unwrap();
        let concurrent_batches: usize = dotenv::var(config::CONCURRENT_BATCHES)
            .unwrap_or(String::from("16"))
            .parse()
            .unwrap();
        Self {
            host,
            queue,
            permits: concurrent_batches,
        }
    }

    pub async fn start(&self) -> Result<()> {
        let conn_res = Connection::connect(&self.host, ConnectionProperties::default()).await;
        match conn_res {
            Ok(conn) => {
                info!(
                    "Dispatcher started at : {} and queue : {}",
                    self.host.clone(),
                    self.queue.clone()
                );
                let channel = conn.create_channel().await?;

                channel.basic_qos(16, BasicQosOptions::default()).await?;

                let storage: Arc<dyn Storage> = Arc::new(LocalStorage::new());
                let service = Arc::new(TransformEngine::new(storage));
                let publisher = Arc::new(RabbitMqPublisher::new().await?);

                let mut consumer = channel
                    .basic_consume(
                        &self.queue,
                        "image_service",
                        BasicConsumeOptions::default(),
                        FieldTable::default(),
                    )
                    .await?;

                let semaphore = Arc::new(Semaphore::new(self.permits));

                while let Some(delivery) = consumer.next().await {
                    let delivery = delivery?;
                    let srv = Arc::clone(&service);
                    let _publisher = Arc::clone(&publisher);
                    let permit = semaphore.clone().acquire_owned().await?;
                    let msg: Result<UploadDto, serde_json::Error> =
                        serde_json::from_slice(&delivery.data);
                    match msg {
                        Ok(dto) => {
                            task::spawn(async move {
                                let _permit = permit;

                                let result = srv.handle(dto).await;

                                match result {
                                    Ok(dto) => {
                                        let _ = delivery.ack(BasicAckOptions::default()).await;
                                        let msg = &serde_json::to_string(&dto).unwrap();
                                        let _ = _publisher.publish(msg).await;
                                    }
                                    Err(e) => {
                                        let _ = delivery.nack(BasicNackOptions::default()).await;
                                        error!("message failed: {e:?}");
                                    }
                                }
                            });
                        }
                        Err(e) => {
                            error!("error deserializing the dto: {}", e);
                            let _ = delivery.nack(BasicNackOptions::default()).await;
                            continue;
                        }
                    }
                }

                Ok(())
            }
            Err(e) => {
                error!("Connection in {} failed", self.host);
                Err(anyhow!(format!("Error: {} opening connection", e)))
            }
        }
    }
}
