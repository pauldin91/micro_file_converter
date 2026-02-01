use std::collections::HashMap;


use image::DynamicImage;

use crate::{domain::{ImageError, Rect}, features::{Transform, decode, encode}};

pub struct Crop {
    selection: Rect,
}
impl Default for Crop {
    fn default() -> Self {
        Self::new()
    }
}

impl Crop {
    pub fn new() -> Self {
        Self {
            selection: Rect {
                x: 0,
                y: 0,
                w: 24,
                h: 24,
            },
        }
    }
    pub fn from(props: &HashMap<String, String>) -> Self {
        let x: u32 = props
            .get("x")
            .unwrap_or(&String::from("0"))
            .parse()
            .unwrap();
        let y: u32 = props
            .get("y")
            .unwrap_or(&String::from("0"))
            .parse()
            .unwrap();
        let width: u32 = props
            .get("width")
            .unwrap_or(&String::from("100"))
            .parse()
            .unwrap();
        let height: u32 = props
            .get("height")
            .unwrap_or(&String::from("100"))
            .parse()
            .unwrap();
        let selection = Rect::new(x, y, width, height);
        Self {
            selection,
        }
    }
}
impl Transform for Crop {
    fn apply(&self, img: &DynamicImage) -> Result<DynamicImage, ImageError> {
        let mut copy = img.clone();
        let cropped = copy.crop(
            self.selection.x,
            self.selection.y,
            self.selection.w,
            self.selection.h,
        );
        Ok(cropped)
    }
}
