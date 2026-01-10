use std::{collections::HashMap, sync::Arc};

use crate::{
    Blur, Brighten, Crop, Fractal, Invert, Rotate, TransformType,
    domain::{ImageTransform, Rect, Storage},
};

pub struct TransformService {
    storage:  Arc<dyn Storage>,
}

impl TransformService {
    pub fn new(storage:Arc<dyn Storage>) -> Self {
        Self { storage: storage }
    }
    pub fn handle(&self, instructions: HashMap<String, String>) {
        let transform_type = instructions.get_key_value("transform").unwrap();
        let parsed_tr = transform_type.1.parse::<TransformType>();
        match parsed_tr {
            Ok(kind) => {
                let op: Box<dyn ImageTransform> = match kind {
                    TransformType::Blur => Box::new(Blur::new(0.5)),
                    TransformType::Brighten => Box::new(Brighten::new()),
                    TransformType::Crop => Box::new(Crop::new(Rect {
                        x: 20,
                        y: 20,
                        w: 200,
                        h: 200,
                    })),
                    TransformType::Fractal => Box::new(Fractal::new()),
                    TransformType::Invert => Box::new(Invert::new()),
                    TransformType::Rotate => Box::new(Rotate::new(90)),
                };
                let filename = self
                    .storage
                    .get_files(instructions.get("id").unwrap().clone());

                for f in filename {
                    let img = self.storage.load(f);
                }
            }
            Err(_) => return,
        }
    }

    pub fn revert(&self) {}
}
