use std::{io::Cursor};

use image::ImageOutputFormat;

use crate::domain::ImageTransform;

pub struct Invert;
impl Invert {
    pub fn new() -> Self {
        Self {}
    }
}
impl ImageTransform for Invert {
    fn apply(&self, img: &[u8]) -> Result<Vec<u8>, image::ImageError>  {
        let mut dynamic_img = image::load_from_memory(img).unwrap();
        dynamic_img.invert();
        let mut out = Vec::new();
        dynamic_img.write_to(&mut Cursor::new(&mut out), ImageOutputFormat::Png)?;
        Ok(out)
    }
}
