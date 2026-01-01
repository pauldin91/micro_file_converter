use std::path::PathBuf;

use image::DynamicImage;


pub struct Invert {
    filename: PathBuf
}
impl Invert {
    pub fn new(filename: PathBuf) -> Self {
        Self { filename: filename }
    }

    pub fn apply(&self) -> DynamicImage {
        let mut img = image::open(&self.filename).expect("Failed to open INFILE.");
        img.invert();
        img
    }

}
