use async_trait::async_trait;

#[async_trait]
pub trait Subscriber: Send + Sync  {
    async fn get_next(&self) -> Result<String, anyhow::Error>;
}
