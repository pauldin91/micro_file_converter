

use image::DynamicImage;

use crate::{domain::ImageError, features::Transform};

pub struct Invert;
impl Default for Invert {
    fn default() -> Self {
        Self::new()
    }
}

impl Invert {
    pub fn new() -> Self {
        Self {}
    }
}
impl Transform for Invert {
    fn apply(&self, img: &DynamicImage) -> Result<DynamicImage, ImageError> {
        let mut copy =img.clone();
        copy.invert();
        Ok(copy)
    }
}
