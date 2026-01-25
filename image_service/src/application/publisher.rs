use lapin::{Connection, ConnectionProperties};

use crate::domain::config;

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

    pub async fn publish(&self, msg: String) {
        let conn_res = Connection::connect(&self.host, ConnectionProperties::default()).await;

        todo!()
    }
}
