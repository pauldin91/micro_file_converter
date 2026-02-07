use std::collections::HashMap;

use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug,Serialize, Deserialize)]
pub enum Status {
    Processing,
    Completed,
    PartiallyCompleted(String),
    Failed,
}

#[derive(Debug, Deserialize)]
pub struct FileDto {
    pub size: u64,
    pub content_type: String,
    pub filename: String,
}

#[derive(Debug, Deserialize)]
pub struct TransformRequestDto {
    pub id: Uuid,
    pub transform: TransformPropertiesDto,
    pub timestamp: DateTime<Utc>,
    pub files: Vec<FileDto>,
}
#[derive(Debug, Deserialize)]
pub struct TransformPropertiesDto{
    pub name: String,
    #[serde(default)]
    pub props: HashMap<String, String>,
}

#[derive(Debug,Serialize, Deserialize)]
pub struct TransformResponseDto {
    pub id: String,
    pub status: Status,
    pub timestamp: DateTime<Utc>
}
impl TransformResponseDto {
    pub fn new(id: String, status: Status) -> Self {
        Self {
            id,
            status,
            timestamp: Utc::now()
        }
    }
}
