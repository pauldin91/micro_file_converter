use std::path::PathBuf;

use image::DynamicImage;



pub struct Rotate {
    filename: PathBuf,
    angle: u16, 
}

impl Rotate {
    pub fn new(filename: PathBuf,angle: u16) -> Self {
        Self { 
            angle: angle,
            filename: filename,
        }
    }
    pub fn apply(&self) -> DynamicImage {
        let img = image::open(&self.filename).expect("Failed to open INFILE.");
        let img2 = match self.angle {
           90=> img.rotate90(),
           180=> img.rotate180(),
           _ => img.rotate270(),
        };
        img2
    }

}
