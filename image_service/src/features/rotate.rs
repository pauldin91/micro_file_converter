use image::{DynamicImage, ImageOutputFormat, Rgba};
use imageproc::geometric_transformations::{Interpolation, rotate_about_center};
use std::{collections::HashMap, io::Cursor};

use crate::{domain::{ImageError, Instructions, Transform}, features::{decode, encode}};

pub struct Rotate {
    degrees: f32,
}

impl Rotate {
    pub fn new() -> Self {
        Self { degrees: 0.0 }
    }
    pub fn from(props: &HashMap<String, String>) -> Self {
        let degrees_key = Instructions::parse_properties::<f32>(&props, &"degrees");

        let angle: f32 = match degrees_key {
            Some(degrees) => degrees,
            None => 90.0,
        };
        Self { degrees: angle }
    }
}

impl Transform for Rotate {
    fn apply(&self, img: &[u8]) -> Result<Vec<u8>, ImageError> {
        let dynamic_img = decode(img)?;

        let rgba = dynamic_img.to_rgba8();

        let angle_radians = -self.degrees.to_radians();

        let background = Rgba([255u8, 255u8, 255u8, 0u8]);

        let rotated =
            rotate_about_center(&rgba, angle_radians, Interpolation::Bilinear, background);

        encode(&DynamicImage::ImageRgba8(rotated))
    }
}
