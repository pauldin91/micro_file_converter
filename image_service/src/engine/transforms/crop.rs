use std::path::PathBuf;

use image::DynamicImage;

use crate::engine::transforms::Rect;
pub struct Crop {
    filename: PathBuf,
    selection: Rect,
}
impl Crop{
    pub fn new(filename: PathBuf,selection: Rect) -> Self {
        Self { 
            selection: selection, 
            filename: filename,
        }
    }

    pub fn apply(&self) -> DynamicImage {
        let mut img = image::open(&self.filename).expect("Failed to open INFILE.");
        img.crop(self.selection.x,self.selection.y,self.selection.w,self.selection.h)
    }

}