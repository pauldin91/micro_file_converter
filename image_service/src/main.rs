use dotenv::dotenv;
use image_service::rabbit;
use std::sync::Arc;

#[tokio::main]
async fn main() {
    dotenv().ok();
    tracing_subscriber::fmt::init();

    let consumer = Arc::new(rabbit::Dispatcher::new());

    let handle = tokio::spawn({
        let consumer = Arc::clone(&consumer);
        async move {
            if let Err(_) = consumer.start().await {
                println!("consumer crashed");
            }
        }
    });

    let _ = handle.await;
}
