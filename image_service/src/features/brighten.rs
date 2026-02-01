use std::collections::HashMap;


use crate::{domain::{ImageError, Instructions, Transform}, features::{decode, encode}};

pub struct Brighten {
    brightness: i32,
}
impl Default for Brighten {
    fn default() -> Self {
        Self::new()
    }
}

impl Brighten {
    pub fn new() -> Self {
        Self {
            brightness: 0,
        }
    }
    pub fn from(props: &HashMap<String, String>) -> Self {
        let br_key = Instructions::parse_properties::<i32>(props, "brightness");

        let brightness: i32 = br_key.unwrap_or_default();
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
