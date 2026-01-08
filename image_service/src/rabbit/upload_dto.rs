use serde::Deserialize;
use uuid::Uuid;
use chrono::{DateTime, Utc};

use crate::rabbit::{FileDto, TransformDto};


#[derive(Debug, Deserialize)]
pub struct UploadDto{
    pub id: Uuid,
    pub transform: TransformDto,
    pub timestamp: DateTime<Utc>,
    pub files: Vec<FileDto>,
}