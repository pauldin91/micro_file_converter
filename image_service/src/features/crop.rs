use std::collections::HashMap;


use image::DynamicImage;

use crate::{domain::{ImageError, Instructions, Rect}, features::Transform};

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
        let x: u32 = Instructions::parse_properties::<u32>(props, "x").unwrap_or(0);
        let y: u32 = Instructions::parse_properties::<u32>(props, "y").unwrap_or(0);
        let width: u32 = Instructions::parse_properties::<u32>(props, "w").unwrap_or(100);
        let height: u32 = Instructions::parse_properties::<u32>(props, "h").unwrap_or(100);
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
