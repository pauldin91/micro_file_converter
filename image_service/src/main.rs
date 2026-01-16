use dotenv::dotenv;
use image_service::rabbit;
use std::sync::Arc;
use tracing_subscriber::FmtSubscriber;
use tracing::error;
#[tokio::main]
async fn main() {
    dotenv().ok();
    let subscriber = FmtSubscriber::new();
    tracing::subscriber::set_global_default(subscriber).expect("setting default failed");

    let dispatcher = Arc::new(rabbit::Dispatcher::new());

    let handle = tokio::spawn({
        let dispatcher = dispatcher.clone();
        async move {
            if let Err(_) = dispatcher.start().await {
                error!("consumer crashed");
            }
        }
    });

    handle.await.unwrap();
}
