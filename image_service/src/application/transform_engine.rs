use anyhow::anyhow;
use std::collections::HashMap;
use std::default;
use std::result::Result::Ok;
use std::str::FromStr;
use std::sync::Arc;
use tracing::{error, info};

use crate::domain::{InstructionParseError, TransformParseError};
use crate::features::Mirror;
use crate::features::mirror::MirrorAxis;
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
                    TransformType::Crop => {
                        let crop_instructions = instructions.get_key_value("rect").unwrap().1;
                        Box::new(Crop::new(Rect::from(crop_instructions)))
                    }
                    TransformType::Mirror => {
                        let axis_key = TransformEngine::try_parse::<String>(&instructions, &"axis");
                        match axis_key {
                            Some(axis) => Box::new(Mirror::new(axis)),
                            None => Box::new(Mirror::new(String::new())),
                        }
                    }
                    TransformType::Blur => {
                        let sigma_key = TransformEngine::try_parse::<f32>(&instructions, &"sigma");

                        match sigma_key {
                            Some(sigma) => Box::new(Blur::new(sigma)),
                            None => Box::new(Blur::new(0.0)),
                        }
                    }
                    TransformType::Brighten => {
                        let value_key = TransformEngine::try_parse::<i32>(&instructions, &"value");

                        match value_key {
                            Some(value) => Box::new(Brighten::new(value)),
                            None => Box::new(Brighten::new(0)),
                        }
                    }
                    TransformType::Rotate => {
                        let degrees_key =
                            TransformEngine::try_parse::<u16>(&instructions, &"degrees");

                        match degrees_key {
                            Some(degrees) => Box::new(Rotate::new(degrees)),
                            None => Box::new(Rotate::new(90)),
                        }
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

    fn try_parse<T>(instructions: &HashMap<String, String>, arg_name: &str) -> Option<T>
    where
        T: FromStr,
    {
        let val = instructions
            .get(arg_name)
            .ok_or_else(|| InstructionParseError::Missing::<String>(arg_name.to_string()));

        match val {
            Ok(res) => match res.parse() {
                Ok(parsed) => Some(parsed),
                Err(e) => {
                    error!("could not parse instruction {}", arg_name);
                    None
                }
            },
            Err(e) => {
                error!("could not parse instruction {}", arg_name);
                None
            }
        }
    }
}
