use serde::Deserialize;
use uuid::Uuid;
use chrono::{DateTime, Utc};

use crate::rabbit::FileDto;


#[derive(Debug, Deserialize)]
pub struct UploadDto{
    pub id: Uuid,
    pub transform: String,
    pub timestamp: DateTime<Utc>,
    pub files: Vec<FileDto>,
}