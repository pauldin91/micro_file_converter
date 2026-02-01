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
pub struct UploadDto {
    pub id: Uuid,
    pub transform: TransformDto,
    pub timestamp: DateTime<Utc>,
    pub files: Vec<FileDto>,
}
#[derive(Debug, Deserialize)]
pub struct TransformDto{
    pub name: String,
    #[serde(default)]
    pub props: HashMap<String, String>,
}

#[derive(Debug,Serialize, Deserialize)]
pub struct CompletedDto {
    pub id: String,
    pub status: Status,
    pub timestamp: DateTime<Utc>
}
impl CompletedDto {
    pub fn new(id: String, status: Status) -> Self {
        Self {
            id: id,
            status: status,
            timestamp: Utc::now()
        }
    }
}
