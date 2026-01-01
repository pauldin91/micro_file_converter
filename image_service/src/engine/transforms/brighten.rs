use std::path::PathBuf;

use image::DynamicImage;

pub struct Brighten {
    filename: PathBuf,
}
impl Brighten {
    pub fn new(filename: PathBuf) -> Self {
        Self { filename: filename }
    }
    pub fn apply(&self) -> DynamicImage {
        let img = image::open(&self.filename).expect("Failed to open INFILE.");
        img.brighten(20)
    }
}
