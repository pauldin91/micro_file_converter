use dotenv::dotenv;
use std::{path::PathBuf, sync::Arc};
use image_service::{engine::transforms::{Fractal, ImageTransform}, rabbit};

#[tokio::main]
async fn main() {
    let tr = Box::new(Fractal::new(PathBuf::from("test.jpeg")));
    let _ =tr.apply_and_save(tr.filename());
    
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

    let _ = handle.await;
}
