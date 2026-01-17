use std::str::FromStr;
use std::error::Error;

use crate::domain::TransformParseError;


#[derive(Debug, Copy, Clone)]
pub enum TransformType {
    Blur,
    Brighten,
    Crop,
    Invert,
    Mirror,
    Rotate
}


impl FromStr for TransformType {
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

pub enum GeneratorType {
    Fractal,
}

impl FromStr for GeneratorType {
    type Err = ();

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "fractal" => Ok(Self::Fractal),
            _ => Err(()),
        }
    }
}