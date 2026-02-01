use std::collections::HashMap;
use super::encoder::*;

use crate::{domain::{ImageError, Instructions, Transform}};

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
    fn apply(&self, img: &[u8]) -> Result<Vec<u8>, ImageError> {
        let dynamic_img = decode(img)?;
        let blurred = dynamic_img.blur(self.sigma);
        encode(&blurred)
    }
}
