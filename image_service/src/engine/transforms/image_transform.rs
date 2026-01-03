use std::path::PathBuf;

use image::ImageError;

use crate::engine::transforms::Transform;

pub trait ImageTransform {
    fn apply(&self) -> image::DynamicImage;
    fn filename(&self) -> PathBuf;

    fn apply_and_save(&self,path: PathBuf) -> Result<(), ImageError> {
        self.apply()
            .save(Transform::get_generic_save_path(path))
    }
}