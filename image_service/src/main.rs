use dotenv::dotenv;
use std::{path::PathBuf, sync::Arc};
use image_service::{engine::transforms::Fractal, rabbit};

#[tokio::main]
async fn main() {
    let tr = Fractal::new(PathBuf::from("test.jpeg"));
    tr.apply();
    dotenv().ok();
    tracing_subscriber::fmt::init();

    let consumer = Arc::new(rabbit::Dispatcher::new());

    let handle = tokio::spawn({
        let consumer = Arc::clone(&consumer);
        async move {
            if let Err(_) = consumer.consume().await {
                println!("consumer crashed");
            }
        }
    });

    // Optional: wait forever (consumer is long-lived)
    let _ = handle.await;
}
