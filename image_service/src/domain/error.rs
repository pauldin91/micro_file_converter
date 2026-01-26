use thiserror::Error;

#[derive(Debug, Error)]
pub enum TransformParseError {
    #[error("invalid transform: '{0}'")]
    Invalid(String),
}

#[derive(Debug, Error)]
pub enum InstructionParseError<E> {
    #[error("property not found: {0}")]
    Missing(String),

    #[error("failed to parse property")]
    Parse(#[source] E),
}


#[derive(Debug, Error)]
pub enum PublishError {
    #[error("RabbitMQ error: {0}")]
    RabbitMq(#[from] lapin::Error),

    #[error("Config error: {0}")]
    Config(#[from] dotenv::Error),
}
