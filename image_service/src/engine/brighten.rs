use std::{io::Cursor};

use image::{ImageError, ImageOutputFormat};

use crate::domain::ImageTransform;

pub struct Brighten;
impl Brighten {
    pub fn new() -> Self {
    Self
    }

}
impl ImageTransform for Brighten {

        fn apply(&self, img: &[u8]) ->Result<Vec<u8>,ImageError> {
        let dynamic_img = image::load_from_memory(img).unwrap(); 
        dynamic_img.brighten(20);
        let mut out = Vec::new();
        dynamic_img.write_to(&mut Cursor::new(&mut out), ImageOutputFormat::Png)?;
        Ok(out)
    }
}
