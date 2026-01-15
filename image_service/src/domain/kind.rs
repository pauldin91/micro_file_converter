use std::str::FromStr;


#[derive(Debug, Copy, Clone)]
pub enum TransformType {
    Blur,
    Brighten,
    Crop,
    Invert,
    Rotate,
    Mirror
}

impl FromStr for TransformType {
    type Err = ();

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "blur" => Ok(Self::Blur),
            "brighten" => Ok(Self::Brighten),
            "crop" => Ok(Self::Crop),
            "invert" => Ok(Self::Invert),
            "rotate" => Ok(Self::Rotate),
            "mirror"=> Ok(Self::Mirror),
            _ => Err(()),
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