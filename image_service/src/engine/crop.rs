use std::io::Cursor;

use image::ImageOutputFormat;

use crate::{domain::{Transform, Rect}};

pub struct Crop {
    selection: Rect,
}
impl Crop {
    pub fn new(selection: Rect) -> Self {
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
