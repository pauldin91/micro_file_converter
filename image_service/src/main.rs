use std::thread::spawn;

use dotenv::dotenv;

use futures_lite::StreamExt;
use image_service::{engine::transforms::Fractal, rabbit};
use lapin::{Connection, ConnectionProperties, options::*, types::FieldTable};
use tracing::info;

#[tokio::main]
async fn main() {
    let tr = Fractal::new(String::from("test.jpg"));
    tr.apply();

    dotenv().ok();

    tracing_subscriber::fmt::init();
    let consumer = rabbit::Consumer::new();

    let handle = tokio::spawn(async move {
        if let Err(e) = consumer.consume().await {
            eprintln!("consumer crashed: {e}");
        }
    });
}
