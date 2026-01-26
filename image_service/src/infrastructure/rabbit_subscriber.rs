use anyhow::{Context, anyhow};
use futures_lite::StreamExt;
use async_trait::async_trait;

use lapin::{
    Connection, ConnectionProperties, Consumer,
    options::{BasicConsumeOptions, BasicQosOptions},
    types::FieldTable,
};
use tracing::{error, info};

use crate::domain::{Subscriber, config};

pub struct RabbitMqSubscriber {
    consumer: Consumer,
}

impl RabbitMqSubscriber {
    pub async fn new() -> Result<Self, anyhow::Error> {
        let host = dotenv::var(config::RABBITMQ_HOST).unwrap();
        let queue = dotenv::var(config::TRANSFORM_QUEUE).unwrap();
        let conn_res = Connection::connect(&host, ConnectionProperties::default()).await;
        match conn_res {
            Ok(conn) => {
                info!(
                    "Dispatcher started at : {} and queue : {}",
                    host.clone(),
                    queue.clone()
                );
                let channel = conn.create_channel().await.unwrap();

                channel
                    .basic_qos(16, BasicQosOptions::default())
                    .await
                    .unwrap();

                let consumer = channel
                    .basic_consume(
                        &queue,
                        "image_service",
                        BasicConsumeOptions::default(),
                        FieldTable::default(),
                    )
                    .await
                    .unwrap();

                Ok(Self { consumer })
            }
            Err(e) => {
                error!("Connection in {} failed", host);
                Err(anyhow!(format!("Error: {} opening connection", e)))
            }
        }
    }
}
#[async_trait]
impl Subscriber for RabbitMqSubscriber{
    async fn get_next(&self) -> Result<String, anyhow::Error> {
        let mut consumer = self.consumer.clone();

        let delivery = consumer
            .next()
            .await
            .ok_or_else(|| anyhow!("consumer stream closed"))?
            .context("could not receive message")?;

        delivery
            .ack(lapin::options::BasicAckOptions::default())
            .await
            .context("failed to ack message")?;

        let message =
            String::from_utf8(delivery.data).context("message payload is not valid UTF-8")?;

        Ok(message)
    }
}
