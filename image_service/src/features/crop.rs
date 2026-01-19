use std::{collections::HashMap, io::Cursor};

use image::ImageOutputFormat;

use crate::domain::{Rect, Transform};

pub struct Crop {
    selection: Rect,
}
impl Crop {
    pub fn new(props: &HashMap<String, String>) -> Self {
        let x: u32 = props.get("x").unwrap_or(&String::from("0")).parse().unwrap();
        let y: u32 = props.get("y").unwrap_or(&String::from("0")).parse().unwrap();
        let width: u32 = props.get("width").unwrap_or(&String::from("100")).parse().unwrap();
        let height: u32 = props.get("height").unwrap_or(&String::from("100")).parse().unwrap();
        let selection= Rect::new(x,y,width,height);
        Self {
            selection: selection,
        }
    }
}
impl Transform for Crop {
    fn apply(&self, img: &[u8]) -> Result<Vec<u8>, image::ImageError> {
        let mut dynamic_img = image::load_from_memory(img).unwrap();
        let cropped = dynamic_img.crop(
            self.selection.x,
            self.selection.y,
            self.selection.w,
            self.selection.h,
        );
        let mut out = Vec::new();
        cropped.write_to(&mut Cursor::new(&mut out), ImageOutputFormat::Png)?;
        Ok(out)
    }
}
