use anyhow::Result;
use std::sync::Arc;
use tokio::{sync::Semaphore, task};
use tracing::{error, info};

use crate::domain::Publisher;
use crate::domain::UploadDto;
use crate::domain::{Storage, config};
use crate::infrastructure::RabbitMqPublisher;
use crate::infrastructure::RabbitMqSubscriber;
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
        info!(
            "Dispatcher started at : {} and queue : {}",
            self.host.clone(),
            self.queue.clone()
        );

        let storage: Arc<dyn Storage> = Arc::new(LocalStorage::new());
        let service = Arc::new(TransformEngine::new(storage));
        let publisher = Arc::new(RabbitMqPublisher::new().await?);
        let subscriber = Arc::new(RabbitMqSubscriber::new().await?);

        let semaphore = Arc::new(Semaphore::new(self.permits));

        loop {
            let srv = Arc::clone(&service);
            let _publisher = Arc::clone(&publisher);
            let permit = semaphore.clone().acquire_owned().await?;
            match subscriber.get_next().await {
                Ok(delivery) => {
                    let msg: Result<UploadDto, serde_json::Error> =
                        serde_json::from_str(delivery.as_str());
                    match msg {
                        Ok(dto) => {
                            task::spawn(async move {
                                let _permit = permit;

                                let result = srv.handle(dto).await;

                                match result {
                                    Ok(dto) => {
                                        let msg = &serde_json::to_string(&dto).unwrap();
                                        let _ = _publisher.publish(msg).await;
                                    }
                                    Err(e) => {
                                        error!("message failed: {e:?}");
                                    }
                                }
                            });
                        }
                        Err(e) => {
                            error!("error deserializing the dto: {}", e);
                            continue;
                        }
                    }
                }
                Err(e) => {
                    error!("Error: {} opening connection", e);
                    ()
                }
            }
        }
    }
}
