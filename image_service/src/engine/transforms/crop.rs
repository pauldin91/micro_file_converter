use std::path::PathBuf;

use image::DynamicImage;

use crate::engine::transforms::{ImageTransform, Rect};
pub struct Crop {
    filename: PathBuf,
    selection: Rect,
}
impl Crop {
    pub fn new(filename: PathBuf, selection: Rect) -> Self {
        Self {
            selection: selection,
            filename: filename,
        }
    }
}
impl ImageTransform for Crop{
    fn filename(&self) -> PathBuf {
        self.filename.clone()
    }

    fn apply(&self) -> DynamicImage {
        let mut img = image::open(&self.filename).expect("Failed to open INFILE.");
        img.crop(
            self.selection.x,
            self.selection.y,
            self.selection.w,
            self.selection.h,
        )
    }
}
