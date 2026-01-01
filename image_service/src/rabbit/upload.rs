use serde::Deserialize;
use uuid::Uuid;
use chrono::{DateTime, Utc};
#[derive(Debug, Deserialize)]
pub struct FileDto {
    pub size: u64,
    #[serde(rename = "type")]
    pub content_type: String,
    pub filename: String,
    pub path: String,
}

#[derive(Debug, Deserialize)]
pub struct UploadDto{
    pub id: Uuid,
    pub transform: String,
    pub timestamp: DateTime<Utc>,
    pub files: Vec<FileDto>,
}