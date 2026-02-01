use std::collections::HashMap;


use image::DynamicImage;

use crate::{domain::{ImageError, Instructions}, features::Transform};

pub struct Brighten {
    brightness: i32,
}
impl Default for Brighten {
    fn default() -> Self {
        Self::new()
    }
}

impl Brighten {
    pub fn new() -> Self {
        Self {
            brightness: 0,
        }
    }
    pub fn from(props: &HashMap<String, String>) -> Self {
        let br_key = Instructions::parse_properties::<i32>(props, "brightness");

        let brightness: i32 = br_key.unwrap_or_default();
        Self { brightness }
    }
}
impl Brighten {}
impl Transform for Brighten {
    fn apply(&self, img: &DynamicImage) -> Result<DynamicImage, ImageError> {
        let brightend = img.brighten(self.brightness);
        Ok(brightend)
    }
}
