use std::{collections::HashMap, str::FromStr};
use tracing::error;
use crate::{Blur, Brighten, Crop, Invert, Rotate, TransformType, domain::{InstructionParseError, Rect, Transform}, features::Mirror};

pub struct TransformFactory;

impl TransformFactory {
    pub fn create(&self,
        instructions: &HashMap<String, String>,
        kind: TransformType,
    ) -> Box<dyn Transform> {
        match kind {
            TransformType::Invert => Box::new(Invert::new()),
            TransformType::Crop => {
                let crop_instructions = instructions.get("rect");
                match crop_instructions{
                    Some(rect)=>Box::new(Crop::new(Rect::from(rect))),
                    None=>Box::new(Crop::new(Rect::from("0,0,0,0")))
                }
            }
            TransformType::Mirror => {
                let axis_key = self.try_parse::<String>(&instructions, &"axis");
                match axis_key {
                    Some(axis) => Box::new(Mirror::new(axis)),
                    None => Box::new(Mirror::new(String::new())),
                }
            }
            TransformType::Blur => {
                let sigma_key = self.try_parse::<f32>(&instructions, &"sigma");

                match sigma_key {
                    Some(sigma) => Box::new(Blur::new(sigma)),
                    None => Box::new(Blur::new(0.0)),
                }
            }
            TransformType::Brighten => {
                let value_key = self.try_parse::<i32>(&instructions, &"value");

                match value_key {
                    Some(value) => Box::new(Brighten::new(value)),
                    None => Box::new(Brighten::new(0)),
                }
            }
            TransformType::Rotate => {
                let degrees_key = self.try_parse::<u16>(&instructions, &"degrees");

                match degrees_key {
                    Some(degrees) => Box::new(Rotate::new(degrees)),
                    None => Box::new(Rotate::new(90)),
                }
            }
        }
    }

    fn try_parse<T>(&self, instructions: &HashMap<String, String>, arg_name: &str) -> Option<T>
    where
        T: FromStr,
    {
        let val = instructions
            .get(arg_name)
            .ok_or_else(|| InstructionParseError::Missing::<String>(arg_name.to_string()));

        match val {
            Ok(res) => match res.parse() {
                Ok(parsed) => Some(parsed),
                Err(_) => {
                    error!("could not parse instruction {}",arg_name);
                    None
                }
            },
            Err(_) => {
                error!("could not parse instruction {}", arg_name);
                None
            }
        }
    }
}
