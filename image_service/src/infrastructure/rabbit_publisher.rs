use crate::domain::{PublishError, Publisher, config};
use rabbitmq_stream_client::{
    Environment, NoDedup, Producer
};
use rabbitmq_stream_client::error::StreamCreateError;
use rabbitmq_stream_client::types::{Message, ResponseCode};
use tracing::info;
use async_trait::async_trait;

pub struct RabbitMqPublisher {
    producer: Producer<NoDedup>,
    stream: String,
}

impl RabbitMqPublisher {
    pub async fn new() -> Result<Self, PublishError> {
        let host = dotenv::var(config::RABBITMQ_HOST).unwrap();
        let stream = dotenv::var(config::PROCESSED_QUEUE).unwrap();

        let environment = Environment::builder()
            .host(&host)
            .build().await?;

        if let Err(e) = environment
            .stream_creator()
            .create(&stream).await
        {
            if let StreamCreateError::Create { status, .. } = &e {
                if *status != ResponseCode::StreamAlreadyExists {
                    return Err(e.into());
                }
            }
        }

        let producer = environment
            .producer()
            .build(&stream).await
            .unwrap();

        Ok(Self { producer, stream })
    }
}

#[async_trait]
impl Publisher for RabbitMqPublisher {
    async fn publish(&self, msg: &String) -> Result<(), PublishError> {
        let _ = self.producer
            .send_with_confirm(
                Message::builder()
                    .body(msg.as_bytes())
                    .build(),
            )
            .await;

        info!("Message published to stream `{}`", self.stream);

        Ok(())
    }
}
