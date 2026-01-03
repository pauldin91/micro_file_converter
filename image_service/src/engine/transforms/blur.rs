use std::path::PathBuf;

use image::DynamicImage;

use crate::engine::transforms::ImageTransform;


pub struct Blur {
    sigma: f32,
    filename: PathBuf,
}

impl Blur {
    pub fn new(filename: PathBuf,sigma: f32) -> Self {
        Self {
            filename: filename,
            sigma: sigma,
        }
    }

}
impl ImageTransform for Blur{
    fn filename(&self) -> PathBuf {
        self.filename.clone()
    }

    fn apply(&self) -> DynamicImage {
        let img = image::open(&self.filename).expect("Failed to open INFILE.");
        img.blur(self.sigma)
    }
}
