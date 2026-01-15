use dotenv::dotenv;
use image_service::rabbit;
use std::sync::Arc;

#[tokio::main]
async fn main() {
    dotenv().ok();
    tracing_subscriber::fmt::init();

    let dispatcher = Arc::new(rabbit::Dispatcher::new());

    let handle = tokio::spawn({
        let dispatcher = dispatcher.clone();
        async move {
            if let Err(_) = dispatcher.start().await {
                tracing::error!("consumer crashed");
            }
        }
    });

    handle.await.unwrap();
}
