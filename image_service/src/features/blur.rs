use std::{collections::HashMap, io::Cursor};

use image::ImageOutputFormat;

use crate::domain::{ImageError, Instructions, Transform};

pub struct Blur {
    sigma: f32,
}

impl Blur {
    pub fn new() -> Self {
        Self { sigma: 0.0 }
    }
    pub fn from(props: &HashMap<String, String>) -> Self {
        let sigma_key = Instructions::parse_properties::<f32>(&props, &"sigma");

        let sigma: f32 = match sigma_key {
            Some(sigma) => sigma,
            None => 0.5,
        };
        Self { sigma: sigma }
    }
}
impl Transform for Blur {
    fn apply(&self, img: &[u8]) -> Result<Vec<u8>, ImageError> {
        let dynamic_img = image::load_from_memory(img).unwrap();
        let blurred = dynamic_img.blur(self.sigma);
        let mut out = Vec::new();
        let _ = blurred
            .write_to(&mut Cursor::new(&mut out), ImageOutputFormat::Png)
            .map_err(|_| ImageError::InvalidFormat(String::from("invalid")));
        Ok(out)
    }
}
