use std::{
    path::PathBuf,
    str::FromStr,
};

use uuid::Uuid;

use crate::engine::transforms::{
    Blur, Brighten, Crop, Fractal, ImageTransform, Invert, Rect, Rotate,
};

#[derive(Debug, Copy, Clone)]
pub enum Transform {
    Blur,
    Brighten,
    Crop,
    Fractal,
    Invert,
    Rotate,
}

impl Transform {
    pub fn get_generic_save_path(filename: PathBuf) -> PathBuf {
        PathBuf::from(Uuid::new_v4().to_string()).join(filename)
    }

    fn get_save_path(method: &str, batch_id: String, filename: &PathBuf) -> PathBuf {
        PathBuf::from(batch_id).join(Self::get_transformed_filename(method, filename))
    }

    fn get_transformed_filename(method: &str, inputfile: &PathBuf) -> PathBuf {
        let filename = format!(
            "{}_{}",
            method,
            inputfile.file_name().unwrap().to_string_lossy()
        );
        PathBuf::from(filename)
    }

    pub fn apply_raw(
        filename: PathBuf,
        batch_id: String,
        transform: &str,
    ) -> Result<(), ()> {
        let kind = transform.parse::<Transform>()?;
        let save_path = Self::get_save_path(transform, batch_id, &filename);

        let op: Box<dyn ImageTransform> = match kind {
            Transform::Blur => Box::new(Blur::new(filename, 0.5)),
            Transform::Brighten => Box::new(Brighten::new(filename)),
            Transform::Crop => Box::new(Crop::new(
                filename,
                Rect {
                    x: 20,
                    y: 20,
                    w: 200,
                    h: 200,
                },
            )),
            Transform::Fractal => Box::new(Fractal::new(filename)),
            Transform::Invert => Box::new(Invert::new(filename)),
            Transform::Rotate => Box::new(Rotate::new(filename, 90)),
        };

        op.apply_and_save(save_path).map_err(|_| ())
    }

    pub fn revert(&self) {}
}

impl FromStr for Transform {
    type Err = ();

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "blur" => Ok(Self::Blur),
            "brighten" => Ok(Self::Brighten),
            "crop" => Ok(Self::Crop),
            "fractal" => Ok(Self::Fractal),
            "invert" => Ok(Self::Invert),
            "rotate" => Ok(Self::Rotate),
            _ => Err(()),
        }
    }
}
