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
pub enum RabbitMqError {
    #[error("RabbitMQ error: {0}")]
    RabbitMq(String),

    #[error("Config error: {0}")]
    Config(String),
}

#[derive(Debug, Error)]
pub enum ImageError {
    #[error("RabbitMQ error: {0}")]
    InvalidFormat(String),

    #[error("Config error: {0}")]
    OutOfBounds(String),
}
