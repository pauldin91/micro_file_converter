use std::{collections::HashMap, io::Cursor};

use image::ImageOutputFormat;

use crate::domain::{ImageError, Instructions, Transform};

pub struct Brighten {
    value: i32,
}
impl Brighten {
    pub fn new(props: String) -> Self {
        let value: i32 = match props.parse() {
            Ok(value) => value,
            Err(_) => 0,
        };
        Self { value: value }
    }
    pub fn from(props: &HashMap<String, String>) -> Self {
        let value_key = Instructions::parse_properties::<i32>(&props, &"value");

        let value: i32 = match value_key {
            Some(value) => value,
            None => 0,
        };
        Self { value: value }
    }
}
impl Brighten{
}
impl Transform for Brighten {

    
    fn apply(&self, img: &[u8]) -> Result<Vec<u8>, ImageError> {
        let dynamic_img = image::load_from_memory(img).unwrap();
        let brightend = dynamic_img.brighten(self.value);
        let mut out = Vec::new();
        let _ = brightend
            .write_to(&mut Cursor::new(&mut out), ImageOutputFormat::Png)
            .map_err(|_| ImageError::InvalidFormat(String::from("invalid")));
        Ok(out)
    }
}
