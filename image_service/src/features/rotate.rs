use image::{DynamicImage, Rgba};
use imageproc::geometric_transformations::{Interpolation, rotate_about_center};
use std::collections::HashMap;

use crate::{domain::{ImageError, Instructions}, features::{Transform}};

pub struct Rotate {
    degrees: f32,
}

impl Default for Rotate {
    fn default() -> Self {
        Self::new()
    }
}

impl Rotate {
    pub fn new() -> Self {
        Self { degrees: 0.0 }
    }
    pub fn from(props: &HashMap<String, String>) -> Self {
        let degrees_key = Instructions::parse_properties::<f32>(props, "degrees");

        let angle: f32 = degrees_key.unwrap_or(90.0);
        Self { degrees: angle }
    }
}

impl Transform for Rotate {
    fn apply(&self, img: &DynamicImage) -> Result<DynamicImage, ImageError> {

        let rgba = img.to_rgba8();

        let angle_radians = -self.degrees.to_radians();

        let background = Rgba([255u8, 255u8, 255u8, 0u8]);

        let rotated =
            rotate_about_center(&rgba, angle_radians, Interpolation::Bilinear, background);

        Ok(DynamicImage::ImageRgba8(rotated))
    }
}
