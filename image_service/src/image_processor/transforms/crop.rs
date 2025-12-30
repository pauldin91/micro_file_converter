use crate::image_processor::transforms::{Transform, transform::get_output_dir};

pub struct Crop {
    completed: bool,
}

impl Transform for Crop {
    fn new() -> Self {
        Self { completed: false }
    }
    fn execute(&self, infile: String) {
        let mut img = image::open(&infile).expect("Failed to open INFILE.");
        let img2 = img.crop(20, 200, 20, 200);
        img2.save(get_output_dir("crop", &infile))
            .expect("Failed writing OUTFILE.");
    }
    fn completed(&self) -> bool {
        self.completed
    }
}