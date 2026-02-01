use std::{collections::HashMap, io::Cursor};

use image::ImageOutputFormat;

use crate::{domain::{ImageError, Instructions, Transform}, features::{decode, encode}};

pub struct Brighten {
    brightness: i32,
}
impl Brighten {
    pub fn new() -> Self {
        Self {
            brightness: 0,
        }
    }
    pub fn from(props: &HashMap<String, String>) -> Self {
        let br_key = Instructions::parse_properties::<i32>(&props, &"brightness");

        let brightness: i32 = match br_key {
            Some(value) => value,
            None => 0,
        };
        Self { brightness }
    }
}
impl Brighten {}
impl Transform for Brighten {
    fn apply(&self, img: &[u8]) -> Result<Vec<u8>, ImageError> {
        let dynamic_img = decode(img)?;
        let brightend = dynamic_img.brighten(self.brightness);
        encode(&brightend)
    }
}
