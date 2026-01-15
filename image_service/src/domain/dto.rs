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

impl UploadDto{
    pub fn to_map(&self) -> HashMap<String,String>{
        let mut props= HashMap::new();
        props.insert(String::from("id"), self.id.to_string());
        props.insert(String::from("transform"), self.transform.name.clone());
        for k in self.transform.props.clone(){
            props.insert(k.0.clone(),k.1.clone());
        }
        props
    }
}

#[derive(Debug, Deserialize)]
pub struct TransformDto{
    pub name: String,
    #[serde(default)]
    pub props: HashMap<String,String>
}

