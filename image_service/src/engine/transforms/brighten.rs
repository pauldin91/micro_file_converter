use std::path::PathBuf;

use image::DynamicImage;

use crate::engine::transforms::ImageTransform;

pub struct Brighten {
    filename: PathBuf,
}
impl Brighten {
    pub fn new(filename: PathBuf) -> Self {
        Self { filename: filename }
    }

}
impl ImageTransform for Brighten {
    fn filename(&self) -> PathBuf {
        self.filename.clone()
    }
    fn apply(&self) -> DynamicImage {
        let img = image::open(&self.filename).expect("Failed to open INFILE.");
        img.brighten(20)
    }
}
