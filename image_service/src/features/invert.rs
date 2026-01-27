use std::io::Cursor;

use image::ImageOutputFormat;

use crate::domain::{ImageError, Transform};

pub struct Invert;
impl Invert {
    pub fn new() -> Self {
        Self {}
    }
}
impl Transform for Invert {
    fn apply(&self, img: &[u8]) -> Result<Vec<u8>, ImageError> {
        let mut dynamic_img = image::load_from_memory(img).unwrap();
        dynamic_img.invert();
        let mut out = Vec::new();
        let _ = dynamic_img
            .write_to(&mut Cursor::new(&mut out), ImageOutputFormat::Png)
            .map_err(|_| ImageError::InvalidFormat(String::from("invalid")));
        Ok(out)
    }
}
