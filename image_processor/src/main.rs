use futures_lite::StreamExt;
use lapin::{Connection, ConnectionProperties, options::*, types::FieldTable};
use tracing::info;

#[tokio::main]
async fn main() {
    if std::env::var("RUST_LOG").is_err() {
        unsafe { std::env::set_var("RUST_LOG", "info") };
    }

    tracing_subscriber::fmt::init();

    let addr = std::env::var("AMQP_ADDR").unwrap_or_else(|_| "amqp://127.0.0.1:5672/%2f".into());

    let conn = Connection::connect(&addr, ConnectionProperties::default())
        .await
        .expect("connection error");

    info!("CONNECTED");

    //receive channel
    let channel = conn.create_channel().await.expect("create_channel");
    info!(state=?conn.status());
    let _ = channel.basic_qos(1, BasicQosOptions::default()).await;

    info!("will consume");
    let mut consumer = channel
        .basic_consume(
            "batch-processing".into(),
            "image-processor".into(),
            BasicConsumeOptions::default(),
            FieldTable::default(),
        )
        .await
        .expect("basic_consume");
    info!(state=?conn.status());

    while let Some(delivery) = consumer.next().await {
        match delivery {
            Ok(delivery) => {
                let body_str = String::from_utf8_lossy(&delivery.data);
                println!("Received: {}", body_str);

                delivery
                    .ack(BasicAckOptions::default())
                    .await
                    .expect("basic_ack");
            }
            Err(err) => {
                eprintln!("Consumer error: {:?}", err);
            }
        }
    }
}
