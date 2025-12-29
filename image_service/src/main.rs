use dotenv::dotenv;
use futures_lite::StreamExt;
use lapin::{Connection, ConnectionProperties, options::*, types::FieldTable};
use tracing::info;


#[tokio::main]
async fn main() {

    dotenv().ok();
    if std::env::var("RUST_LOG").is_err() {
        unsafe { std::env::set_var("RUST_LOG", "info") };
    }

    tracing_subscriber::fmt::init();

    let rabbitmq_host =
        std::env::var("RABBITMQ_HOST")
        .expect("env wasn't set");
    let transform_queue =
        std::env::var("TRANSFORM_QUEUE")
        .expect("env wasn't set");

    let conn = Connection::connect(&rabbitmq_host, ConnectionProperties::default())
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
            &transform_queue,
            "image_service".into(),
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
