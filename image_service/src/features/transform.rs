use image::DynamicImage;

use crate::domain::error::ImageError;

pub trait Transform {
    fn apply(&self, img: &DynamicImage) -> Result<DynamicImage, ImageError>;
}
