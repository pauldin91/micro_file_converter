use std::io::Cursor;

use image::ImageOutputFormat;

use crate::{domain::{ImageError, Transform}, features::{decode, encode}};

pub struct Invert;
impl Invert {
    pub fn new() -> Self {
        Self {}
    }
}
impl Transform for Invert {
    fn apply(&self, img: &[u8]) -> Result<Vec<u8>, ImageError> {
        let mut dynamic_img = decode(img)?;
        dynamic_img.invert();
        encode(&dynamic_img)
    }
}
