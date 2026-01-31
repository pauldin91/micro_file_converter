use image::{DynamicImage, ImageOutputFormat, Rgba};
use imageproc::geometric_transformations::{Interpolation, rotate_about_center};
use std::{collections::HashMap, io::Cursor};

use crate::domain::{ImageError, Instructions, Transform};

pub struct Rotate {
    angle: f32,
}

impl Rotate {
    pub fn new(props: &HashMap<String, String>) -> Self {
        let degrees_key = Instructions::parse_properties::<f32>(&props, &"degrees");

        let angle: f32 = match degrees_key {
            Some(degrees) => degrees,
            None => 90.0,
        };
        Self { angle }
    }
}

impl Transform for Rotate {


    fn apply(&self, img: &[u8]) -> Result<Vec<u8>, ImageError> {
        let dynamic_img = image::load_from_memory(img)
            .map_err(|_| ImageError::InvalidFormat(String::from("invalid")))
            .unwrap();

        let rgba = dynamic_img.to_rgba8();

        // Convert degrees to radians (imageproc uses radians)
        let angle_radians = -self.angle.to_radians(); // Negative for clockwise rotation

        // Define the background color (transparent or white)
        let background = Rgba([255u8, 255u8, 255u8, 0u8]); // Transparent white

        // Rotate the image around its center with bilinear interpolation
        let rotated =
            rotate_about_center(&rgba, angle_radians, Interpolation::Bilinear, background);
            
        let mut out = Vec::new();
        let _ = DynamicImage::ImageRgba8(rotated)
            .write_to(&mut Cursor::new(&mut out), ImageOutputFormat::Png)
            .map_err(|_| ImageError::InvalidFormat(String::from("invalid")));
        Ok(out)
    }
}
