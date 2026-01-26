use crate::domain::{PublishError, Publisher, config};
use async_trait::async_trait;
use lapin::{
    BasicProperties, Channel, Connection, ConnectionProperties, options::*, types::FieldTable
};
use tracing::info;

pub struct RabbitMqPublisher {
    channel: Channel,
    exchange: String,
    routing_key: String,
}

impl RabbitMqPublisher {
    pub async fn new() -> Result<Self, PublishError> {
        let uri = dotenv::var(config::RABBITMQ_HOST)?;
        let routing_key = dotenv::var(config::PROCESSED_QUEUE)?;
        let exchange = String::from("processed.exchange");
        let connection = Connection::connect(&uri, ConnectionProperties::default()).await?;

        let channel = connection.create_channel().await?;

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
            .await?;

        channel
            .queue_declare(
                &routing_key,
                QueueDeclareOptions {
                    durable: true,
                    ..Default::default()
                },
                FieldTable::default(),
            )
            .await?;

        channel
            .queue_bind(
                &routing_key,
                &exchange,
                &routing_key,
                QueueBindOptions::default(),
                FieldTable::default(),
            )
            .await?;

        // Enable confirms
        channel
            .confirm_select(ConfirmSelectOptions::default())
            .await?;

        Ok(Self {
            channel,
            exchange,
            routing_key,
        })
    }
}

#[async_trait]
impl Publisher for RabbitMqPublisher {
    async fn publish(&self, msg: &String) -> Result<(), PublishError> {
        let confirm = self
            .channel
            .basic_publish(
                &self.exchange,
                &self.routing_key,
                BasicPublishOptions::default(),
                msg.as_bytes(),
                BasicProperties::default(),
            )
            .await?
            .await?;

        if confirm.is_nack() {
            return Err(PublishError::RabbitMq(lapin::Error::InvalidChannelState(
                lapin::ChannelState::Error,
            )));
        }

        info!(
            "Message published to exchange `{}` with key `{}`",
            self.exchange, self.routing_key
        );

        Ok(())
    }
}
