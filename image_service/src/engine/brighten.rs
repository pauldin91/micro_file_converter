use std::io::Cursor;

use image::{ImageError, ImageOutputFormat};

use crate::domain::ImageTransform;

pub struct Brighten {
    value: i32,
}
impl Brighten {
    pub fn new(value: i32) -> Self {
        Self { value: value }
    }
}
impl ImageTransform for Brighten {
    fn apply(&self, img: &[u8]) -> Result<Vec<u8>, ImageError> {
        let dynamic_img = image::load_from_memory(img).unwrap();
        let brightend = dynamic_img.brighten(self.value);
        let mut out = Vec::new();
        brightend.write_to(&mut Cursor::new(&mut out), ImageOutputFormat::Png)?;
        Ok(out)
    }
}
