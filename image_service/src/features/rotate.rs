use image::ImageOutputFormat;
use std::{collections::HashMap, io::Cursor};

use crate::domain::{ImageError, Instructions, Transform};

pub struct Rotate {
    angle: u16,
}

impl Rotate {
    pub fn new(props: &HashMap<String, String>) -> Self {
        let degrees_key = Instructions::parse_properties::<u16>(&props, &"degrees");

        let angle: u16 = match degrees_key {
            Some(degrees) => degrees,
            None => 90,
        };
        Self { angle }
    }
}

impl Transform for Rotate {
    fn apply(&self, img: &[u8]) -> Result<Vec<u8>, ImageError> {
        let dynamic_img = image::load_from_memory(img)
            .map_err(|_| ImageError::InvalidFormat(String::from("invalid")))
            .unwrap();

        let transformed: image::DynamicImage = match self.angle {
            90 => dynamic_img.rotate90(),
            180 => dynamic_img.rotate180(),
            270 => dynamic_img.rotate270(),
            _ => {
                return Err(ImageError::InvalidFormat((String::from("invalid"))));
            }
        };

        let mut out = Vec::new();
        transformed
            .write_to(&mut Cursor::new(&mut out), ImageOutputFormat::Png)
            .map_err(|_| ImageError::InvalidFormat((String::from("invalid"))));
        Ok(out)
    }
}
