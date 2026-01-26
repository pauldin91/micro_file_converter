use crate::{
    Publisher,
    domain::{RabbitMqError, config},
};
use async_trait::async_trait;
use lapin::{
    BasicProperties, Channel, Connection, ConnectionProperties, options::*, types::FieldTable,
};
use tracing::info;

pub struct RabbitMqPublisher {
    channel: Channel,
    exchange: String,
    routing_key: String,
}

impl RabbitMqPublisher {
    pub async fn new() -> Result<Self, RabbitMqError> {
        let uri = dotenv::var(config::RABBITMQ_HOST).unwrap();
        let routing_key = dotenv::var(config::PROCESSED_QUEUE).unwrap();
        let exchange = String::from("processed.exchange");
        let connection = Connection::connect(&uri, ConnectionProperties::default())
            .await
            .unwrap();

        let channel = connection.create_channel().await.unwrap();

        channel
            .exchange_declare(
                &exchange,
                lapin::ExchangeKind::Direct,
                ExchangeDeclareOptions {
                    durable: true,
                    ..Default::default()
                },
                FieldTable::default(),
            )
            .await
            .unwrap();

        channel
            .queue_declare(
                &routing_key,
                QueueDeclareOptions {
                    durable: true,
                    ..Default::default()
                },
                FieldTable::default(),
            )
            .await
            .unwrap();

        channel
            .queue_bind(
                &routing_key,
                &exchange,
                &routing_key,
                QueueBindOptions::default(),
                FieldTable::default(),
            )
            .await
            .unwrap();

        // Enable confirms
        channel
            .confirm_select(ConfirmSelectOptions::default())
            .await
            .unwrap();

        Ok(Self {
            channel,
            exchange,
            routing_key,
        })
    }
}

#[async_trait]
impl Publisher for RabbitMqPublisher {
    async fn publish(&self, msg: &String) -> Result<(), RabbitMqError> {
        let confirm = self
            .channel
            .basic_publish(
                &self.exchange,
                &self.routing_key,
                BasicPublishOptions::default(),
                msg.as_bytes(),
                BasicProperties::default(),
            )
            .await
            .unwrap()
            .await
            .unwrap();

        if confirm.is_nack() {
            return Err(RabbitMqError::RabbitMq(String::from("unable to publish")));
        }

        info!(
            "Message published to exchange `{}` with key `{}`",
            self.exchange, self.routing_key
        );

        Ok(())
    }
}
