use image::{DynamicImage, ImageOutputFormat};
use std::io::Cursor;

use crate::domain::ImageError;

pub fn decode(img: &[u8]) -> Result<DynamicImage, ImageError> {
    image::load_from_memory(img).map_err(|e| ImageError::InvalidFormat(e.to_string()))
}

pub fn encode(img: &DynamicImage) -> Result<Vec<u8>, ImageError> {
    let mut out = Vec::new();
    img.write_to(&mut Cursor::new(&mut out), ImageOutputFormat::Png)
        .map_err(|e| ImageError::InvalidFormat(e.to_string()))?;
    Ok(out)
}
