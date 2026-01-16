use std::str::FromStr;
use std::error::Error;


#[derive(Debug, Copy, Clone)]
pub enum TransformType {
    Blur,
    Brighten,
    Crop,
    Invert,
    Rotate,
    Mirror
}
use thiserror::Error;

#[derive(Debug, Error)]
pub enum TransformParseError {
    #[error("invalid transform: '{0}'")]
    Invalid(String),
}

impl FromStr for TransformType {
    type Err = TransformParseError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "blur" => Ok(Self::Blur),
            "brighten" => Ok(Self::Brighten),
            "crop" => Ok(Self::Crop),
            "invert" => Ok(Self::Invert),
            "rotate" => Ok(Self::Rotate),
            "mirror" => Ok(Self::Mirror),
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