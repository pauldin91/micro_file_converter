use std::path::PathBuf;

use image::DynamicImage;

use crate::engine::transforms::ImageTransform;

pub struct Invert {
    filename: PathBuf,
}
impl Invert {
    pub fn new(filename: PathBuf) -> Self {
        Self { filename: filename }
    }
}
impl ImageTransform for Invert{
    fn filename(&self) -> PathBuf {
        self.filename.clone()
    }

    fn apply(&self) -> DynamicImage {
        let mut img = image::open(&self.filename).expect("Failed to open INFILE.");
        img.invert();
        img
    }
}
