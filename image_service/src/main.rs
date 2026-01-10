use dotenv::dotenv;
use image_service::rabbit;
use std::sync::Arc;

#[tokio::main]
async fn main() {
    dotenv().ok();
    tracing_subscriber::fmt::init();

    // let rabbitmq_host = std::env::var("RABBITMQ_HOST").expect("env wasn't set");
    // let transform_queue = std::env::var("TRANSFORM_QUEUE").expect("env wasn't set");
    // let upload_dir = std::env::var("UPLOAD_DIR").expect("env wasn't set");

    let consumer = Arc::new(rabbit::Dispatcher::new());

    let handle = tokio::spawn({
        let consumer = Arc::clone(&consumer);
        async move {
            if let Err(_) = consumer.consume().await {
                println!("consumer crashed");
            }
        }
    });

    let _ = handle.await;
}
