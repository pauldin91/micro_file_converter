use std::str::FromStr;


#[derive(Debug, Copy, Clone)]
pub enum TransformType {
    Blur,
    Brighten,
    Crop,
    // Fractal,
    Invert,
    Rotate,
}

impl FromStr for TransformType {
    type Err = ();

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "blur" => Ok(Self::Blur),
            "brighten" => Ok(Self::Brighten),
            "crop" => Ok(Self::Crop),
            // "fractal" => Ok(Self::Fractal),
            "invert" => Ok(Self::Invert),
            "rotate" => Ok(Self::Rotate),
            _ => Err(()),
        }
    }
}