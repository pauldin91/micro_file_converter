use dotenv::dotenv;
use image_service::application;
use std::sync::Arc;
use tracing_subscriber::FmtSubscriber;
use tracing::error;
#[tokio::main]
async fn main() {
    dotenv().ok();
    let subscriber = FmtSubscriber::new();
    tracing::subscriber::set_global_default(subscriber).expect("setting default failed");

    let dispatcher = Arc::new(application::Dispatcher::new());

    let handle = tokio::spawn({
        let dispatcher = dispatcher.clone();
        async move {
            if let Err(e) = dispatcher.start().await {
                error!("error : {}",e);
                error!("consumer crashed");
            }
        }
    });

    handle.await.unwrap();
}
