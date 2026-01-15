use std::io::Cursor;

use image::{ImageError, ImageOutputFormat};

use crate::domain::Transform;

pub struct Blur {
    sigma: f32,
}

impl Blur {
    pub fn new(sigma: f32) -> Self {
        Self { sigma: sigma }
    }
}
impl Transform for Blur {
    fn apply(&self, img: &[u8]) -> Result<Vec<u8>, ImageError> {
        let dynamic_img = image::load_from_memory(img).unwrap();
        let blurred = dynamic_img.blur(self.sigma);
        let mut out = Vec::new();
        blurred.write_to(&mut Cursor::new(&mut out), ImageOutputFormat::Png)?;
        Ok(out)
    }
}
