use serde::Deserialize;

#[derive(Debug, Deserialize)]
pub struct FileDto {
    pub size: u64,
    #[serde(rename = "type")]
    pub content_type: String,
    pub filename: String,
    pub path: String,
}