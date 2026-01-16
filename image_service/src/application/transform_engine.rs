use anyhow::anyhow;
use std::collections::HashMap;
use std::default;
use std::result::Result::Ok;
use std::str::FromStr;
use std::sync::Arc;
use tracing::{error, info};

use crate::domain::InstructionParseError;
use crate::features::Mirror;
use crate::{
    Blur, Brighten, Crop, Invert, Rotate, TransformType,
    domain::{Rect, Storage, Transform},
};
#[derive(Clone)]
pub struct TransformEngine {
    storage: Arc<dyn Storage>,
}
impl TransformEngine {
    pub fn new(storage: Arc<dyn Storage>) -> Self {
        Self { storage: storage }
    }
    pub fn handle(&self, instructions: HashMap<String, String>) -> Result<(), anyhow::Error> {
        let transform_type = instructions.get_key_value("transform").unwrap();
        info!("parsed : {:?}", instructions);
        let parsed_tr = transform_type.1.parse::<TransformType>();
        match parsed_tr {
            Ok(kind) => {
                let op: Box<dyn Transform> = match kind {
                    TransformType::Invert => Box::new(Invert::new()),
                    TransformType::Mirror => {
                        let axis: String = instructions
                            .get_key_value("axis")
                            .unwrap()
                            .1
                            .parse()
                            .unwrap();
                        Box::new(Mirror::new(axis))
                    }
                    TransformType::Blur => {
                        let sigma: f32 = instructions
                            .get_key_value("sigma")
                            .unwrap()
                            .1
                            .parse()
                            .unwrap();
                        Box::new(Blur::new(sigma))
                    }
                    TransformType::Brighten => {
                        let value: i32 = instructions
                            .get_key_value("value")
                            .unwrap()
                            .1
                            .parse()
                            .unwrap();
                        Box::new(Brighten::new(value))
                    }
                    TransformType::Crop => {
                        let crop_instructions = instructions.get_key_value("rect").unwrap().1;
                        Box::new(Crop::new(Rect::from(crop_instructions)))
                    }
                    TransformType::Rotate => {
                        let degrees: u16 = instructions
                            .get_key_value("degrees")
                            .unwrap()
                            .1
                            .parse()
                            .unwrap();
                        Box::new(Rotate::new(degrees))
                    }
                };
                let dir = instructions.get("id").unwrap().clone();
                let filenames: Vec<String> = self
                    .storage
                    .get_files(&dir)
                    .iter()
                    .filter(|s| !s.as_str().ends_with(".json"))
                    .map(|p| p.clone())
                    .collect();

                for f in filenames {
                    let res = self.storage.load(&f);
                    match res {
                        Ok(img) => {
                            let new_filename =
                                self.storage.get_transformed_filename(&f, &transform_type.1);
                            let transformed = op.apply(&img).unwrap();
                            self.storage.store_file(&new_filename, &transformed);
                        }
                        Err(e) => {
                            error!("error : {}, transforming file: {}", e, f);
                            continue;
                        }
                    }
                }
                Ok(())
            }
            Err(e) => {
                error!("Error: {} invalid transform type", e);
                Err(anyhow!("invalid transform"))
            }
        }
    }

    fn try_parse<T>(
        instructions: &HashMap<String, String>,
        arg_name: &str,
    ) -> Result<T, InstructionParseError<T::Err>>
    where
        T: FromStr,
    {
        let val = instructions
            .get(arg_name)
            .ok_or_else(|| InstructionParseError::Missing(arg_name.to_string()))?;

        val.parse().map_err(InstructionParseError::Parse)
    }
}

