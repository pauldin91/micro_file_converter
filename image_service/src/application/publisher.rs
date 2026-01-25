use crate::domain::config;
use lapin::{Connection, ConnectionProperties};
use rabbitmq_stream_client::Environment;
use rabbitmq_stream_client::error::StreamCreateError;
use rabbitmq_stream_client::types::{ByteCapacity, Message, ResponseCode, StreamCreator};
use tracing::info;

pub struct RabbitMqPublisher {
    host: String,
    queue: String,
}

impl RabbitMqPublisher {
    pub fn new() -> Self {
        let host = dotenv::var(config::RABBITMQ_HOST).unwrap();
        let queue = dotenv::var(config::PROCESSED_QUEUE).unwrap();
        Self { host, queue }
    }

    pub async fn publish(&self, msg: String) -> Result<(), Box<dyn std::error::Error>> {
        use rabbitmq_stream_client::Environment;
        let environment = Environment::builder().host(&self.host).build().await?;
        let stream = msg.as_str();
        let create_response = environment
            .stream_creator()
            .max_length(ByteCapacity::GB(5))
            .create(&self.queue)
            .await;

        if let Err(e) = create_response {
            if let StreamCreateError::Create { stream, status } = e {
                match status {
                    ResponseCode::StreamAlreadyExists => {}
                    err => {
                        println!("Error creating stream: {:?} {:?}", stream, err);
                    }
                }
            }
        }

        let producer = environment.producer().build(stream).await?;

        producer
            .send_with_confirm(Message::builder().body(stream).build())
            .await?;
        info!("Sent message to stream: {}", stream);
        producer.close().await?;
        Ok(())
    }
}
