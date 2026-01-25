use async_trait::async_trait;

use crate::domain::PublishError;

#[async_trait]
pub trait Publisher: Send + Sync {
    async fn publish(&self, msg: &String) -> Result<(), PublishError>;
}