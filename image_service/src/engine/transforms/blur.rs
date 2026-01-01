use std::path::PathBuf;

use image::DynamicImage;


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

    pub fn apply(&self) -> DynamicImage {
        let img = image::open(&self.filename).expect("Failed to open INFILE.");
        img.blur(self.sigma)
    }

}
