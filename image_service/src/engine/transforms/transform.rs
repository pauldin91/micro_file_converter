use std::path::{Path, PathBuf};

use serde_json::to_string;
use uuid::Uuid;

use crate::engine::transforms::{Blur, Brighten, Crop, Fractal, Invert, Rect, Rotate};

pub enum Transform {
    Blur(Blur),
    Brighten(Brighten),
    Crop(Crop),
    Fractal(Fractal),
    Invert(Invert),
    Rotate(Rotate),
}

impl Transform {
    pub fn apply(&self) {
    //     match self {
    //         Transform::Blur(t) => t.apply(),
    //         Transform::Brighten(t) => t.apply(),
    //         Transform::Crop(t) => t.apply(),
    //         Transform::Fractal(t) => t.apply(),
    //         Transform::Invert(t) => t.apply(),
    //         Transform::Rotate(t) => t.apply(),
    //     }
    }

    fn get_save_path(method: String, batch_id: String, filename: &PathBuf) -> PathBuf {
        PathBuf::from(batch_id).join(Transform::get_transformed_filename(method.as_str(), filename))
    }
    fn get_transformed_filename(method: &str, inputfile: &PathBuf) -> PathBuf {
        let filename = method.to_owned() + "_" + inputfile.to_str().unwrap();
        PathBuf::from(filename)
    }

    pub fn apply_raw(filename: PathBuf, batch_id: String,transform: &str) -> Result<(), ()> {
        let save_path = Transform::get_save_path(transform.to_string(), batch_id, &filename);
        match transform {
            "blur" => {
                let blur = Blur::new(filename.clone(), 0.5);
                blur.apply().save(save_path);
                Ok(())
            }
            "brighten" => {
                let brigthen = Brighten::new(filename.clone());
                brigthen.apply().save(save_path);
                Ok(())
            }
            "crop" => {
                let crop = Crop::new(
                    filename.clone(),
                    Rect {
                        x: 20,
                        y: 20,
                        w: 200,
                        h: 200,
                    },
                );
                crop.apply().save(save_path);
                Ok(())
            }
            "fractal" => {
                let fractal = Fractal::new(filename.clone());
                fractal.apply().save(save_path);
                Ok(())
            }
            "invert" => {
                let invert = Invert::new(filename.clone());
                invert.apply().save(save_path);
                Ok(())
            }
            "rotate" => {
                let rotate = Rotate::new(filename.clone(), 90);
                rotate.apply().save(save_path);
                Ok(())
            }
            _ => Err(()),
        }
    }
    pub fn revert(&self) {}
}


