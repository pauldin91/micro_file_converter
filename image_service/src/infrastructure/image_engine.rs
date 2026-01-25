use anyhow::anyhow;
use std::result::Result::Ok;
use std::sync::Arc;
use tracing::error;

use crate::domain::{CompletedDto, UploadDto};
use crate::domain::{Storage, Transform};
use crate::features::TransformFactory;
#[derive(Clone)]
pub struct TransformEngine {
    storage: Arc<dyn Storage>,
}
impl TransformEngine {
    pub fn new(storage: Arc<dyn Storage>) -> Self {
        Self { storage: storage }
    }
    pub async fn handle(&self, instructions: UploadDto) -> Result<CompletedDto, anyhow::Error> {
        match instructions.transform.name.parse::<TransformFactory>() {
            Ok(kind) => {
                let op: Box<dyn Transform> = kind.create(&instructions.transform.props);

                let filenames: Vec<String> = self
                    .storage
                    .get_files(&instructions.id.to_string())
                    .iter()
                    .filter(|s| !s.as_str().ends_with(".json"))
                    .map(|p| p.clone())
                    .collect();

                for f in filenames {
                    let res = self.storage.load(&f);
                    match res {
                        Ok(img) => {
                            let new_filename = self
                                .storage
                                .get_transformed_filename(&f, &instructions.transform.name);
                            let transformed = op.apply(&img).unwrap();
                            self.storage.store_file(&new_filename, &transformed);
                        }
                        Err(e) => {
                            error!("error : {}, transforming file: {}", e, f);
                            continue;
                        }
                    }
                }
                Ok(CompletedDto {
                    id: instructions.id.to_string(),
                    status: crate::domain::Status::Completed,
                })
            }
            Err(e) => {
                error!("Error: {} invalid transform type", e);
                Err(anyhow!("invalid transform"))
            }
        }
    }
}
