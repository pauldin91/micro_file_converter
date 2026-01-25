use anyhow::anyhow;
use lapin::{Connection, ConnectionProperties, Consumer, options::{BasicConsumeOptions, BasicQosOptions}, types::FieldTable};
use tracing::{error, info};

use crate::domain::config;

pub struct RabbitMqSubscriber {
    host: String,
    queue: String,
}

impl RabbitMqSubscriber {
    pub fn new() -> Self {
        let host = dotenv::var(config::RABBITMQ_HOST).unwrap();
        let queue = dotenv::var(config::TRANSFORM_QUEUE).unwrap();
        Self { host, queue }
    }

    pub async fn subscribe(&self) -> Result<Consumer,anyhow::Error> {
        let conn_res = Connection::connect(&self.host, ConnectionProperties::default()).await;
        match conn_res {
            Ok(conn) => {
                info!(
                    "Dispatcher started at : {} and queue : {}",
                    self.host.clone(),
                    self.queue.clone()
                );
                let channel = conn.create_channel().await.unwrap();

                channel.basic_qos(16, BasicQosOptions::default()).await.unwrap();

            

                let mut consumer = channel
                    .basic_consume(
                        &self.queue,
                        "image_service",
                        BasicConsumeOptions::default(),
                        FieldTable::default(),
                    )
                    .await
                    .unwrap();
               Ok(consumer)

            }
            Err(e) => {
                error!("Connection in {} failed", self.host);
                Err(anyhow!(format!("Error: {} opening connection", e)))
            }
        }
    }
}
