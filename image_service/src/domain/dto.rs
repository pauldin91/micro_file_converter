use std::{collections::HashMap};

use chrono::{DateTime, Utc};
use serde::Deserialize;
use uuid::Uuid;

#[derive(Debug, Deserialize)]
pub struct FileDto {
    pub size: u64,
    pub content_type: String,
    pub filename: String,
}

#[derive(Debug, Deserialize)]
pub struct UploadDto{
    pub id: Uuid,
    pub transform: TransformDto,
    pub timestamp: DateTime<Utc>,
    pub files: Vec<FileDto>,
}
#[derive(Debug, Deserialize)]
pub struct TransformDto{
    pub name: String,
    #[serde(default)]
    pub props: HashMap<String,String>
}
