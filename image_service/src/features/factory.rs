use std::{collections::HashMap, str::FromStr};

use crate::{
    Blur, Brighten, Crop, Invert, Rotate,
    domain::TransformParseError,
    features::{Mirror, Transform},
};

#[derive(Debug, Copy, Clone)]
pub enum TransformFactory {
    Blur,
    Brighten,
    Crop,
    Invert,
    Mirror,
    Rotate,
}

impl TransformFactory {

    pub fn create_from_instructions(
        &self,
        instructions: &HashMap<String, String>,
    ) -> Box<dyn Transform> {
        match self {
            TransformFactory::Invert => Box::new(Invert::new()),
            TransformFactory::Crop => Box::new(Crop::from(instructions)),
            TransformFactory::Mirror => Box::new(Mirror::from(instructions)),
            TransformFactory::Blur => Box::new(Blur::from(instructions)),
            TransformFactory::Brighten => Box::new(Brighten::from(instructions)),
            TransformFactory::Rotate => Box::new(Rotate::from(instructions)),
        }
    }
}

impl FromStr for TransformFactory {
    type Err = TransformParseError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "blur" => Ok(Self::Blur),
            "brighten" => Ok(Self::Brighten),
            "crop" => Ok(Self::Crop),
            "invert" => Ok(Self::Invert),
            "mirror" => Ok(Self::Mirror),
            "rotate" => Ok(Self::Rotate),
            _ => Err(TransformParseError::Invalid(s.to_owned())),
        }
    }
}

pub enum GeneratorFactory {
    Fractal,
}

impl FromStr for GeneratorFactory {
    type Err = ();

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "fractal" => Ok(Self::Fractal),
            _ => Err(()),
        }
    }
}
