use std::collections::HashMap;
use image::DynamicImage;


use crate::{domain::{ImageError, Instructions}, features::Transform};

pub struct Blur {
    sigma: f32,
}

impl Default for Blur {
    fn default() -> Self {
        Self::new()
    }
}

impl Blur {
    pub fn new() -> Self {
        Self { sigma: 0.0 }
    }
    pub fn from(props: &HashMap<String, String>) -> Self {
        let sigma_key = Instructions::parse_properties::<f32>(props, "sigma");

        let sigma: f32 = sigma_key.unwrap_or(0.5);
        Self { sigma }
    }
}
impl Transform for Blur {
    fn apply(&self, img: &DynamicImage) -> Result<DynamicImage, ImageError> {
        let blurred = img.blur(self.sigma);
        Ok(blurred)
    }
}
