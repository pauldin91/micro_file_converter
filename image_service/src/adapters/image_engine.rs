use anyhow::anyhow;
use std::result::Result::Ok;
use std::sync::Arc;
use tracing::error;

use crate::Storage;
use crate::domain::{CompletedDto, UploadDto};
use crate::features::{Transform, TransformFactory, decode, encode};
#[derive(Clone)]
pub struct TransformEngine{
    storage: Arc<dyn Storage>,
}
impl TransformEngine {
    pub fn new(storage: Arc<dyn Storage>) -> Self {
        Self { storage }
    }
    pub async fn handle(&self, instructions: UploadDto) -> Result<CompletedDto, anyhow::Error> {
        match instructions.transform.name.parse::<TransformFactory>() {
            Ok(kind) => {
                let op: Box<dyn Transform> = kind.create_from_instructions(&instructions.transform.props);

                let filenames: Vec<String> = self
                    .storage
                    .list_dir(&instructions.id.to_string())
                    .iter()
                    .filter(|s| !s.as_str().ends_with(".json")).cloned()
                    .collect();

                for f in filenames {
                    let res = self.storage.load(&f);
                    match res {
                        Ok(bytes) => {
                            let new_filename = self
                                .storage
                                .get_transformed_filename(&f, &instructions.transform.name);
                            let img = decode(&bytes).unwrap();
                            let transformed = op.apply(&img).unwrap();
                            self.storage.save(&new_filename, &encode(&transformed).unwrap());
                        }
                        Err(e) => {
                            error!("error : {}, transforming file: {}", e, f);
                            continue;
                        }
                    }
                }
                Ok(CompletedDto::new(
                    instructions.id.to_string(),
                    crate::domain::Status::Completed,
                ))
            }
            Err(e) => {
                error!("Error: {} invalid transform type", e);
                Err(anyhow!("invalid transform"))
            }
        }
    }
}
