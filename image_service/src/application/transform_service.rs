use std::collections::HashMap;

use crate::{Blur, Brighten, Crop, Fractal, Invert, Rotate, TransformType, domain::{ImageTransform, Rect}};

pub struct TransformService;

impl TransformService {
    pub fn handle(instructions: HashMap<String, String>) -> Result<(),()> {
        let transform_type = instructions.get_key_value("transform");
        match transform_type {
            Some(tr) =>{
              let kind = tr.1.parse::<TransformType>()?;

              let filename = String::new();
              
              let op: Box<dyn ImageTransform> = match kind {
                  TransformType::Blur => Box::new(Blur::new( 0.5)),
                  TransformType::Brighten => Box::new(Brighten::new()),
                  TransformType::Crop => Box::new(Crop::new(
                      
                      Rect {
                          x: 20,
                          y: 20,
                          w: 200,
                          h: 200,
                      },
                  )),
                  TransformType::Fractal => Box::new(Fractal::new()),
                  TransformType::Invert => Box::new(Invert::new()),
                  TransformType::Rotate => Box::new(Rotate::new( 90)),
              };
              Ok(())
            },
            None   =>Err(()),
        }
    }

    pub fn revert(&self) {}
}
