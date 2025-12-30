use crate::image_processor::transforms::{Transform, transform::get_output_dir};

pub struct Brighten {
    completed: bool,
}

impl Transform for Brighten {
    fn new() -> Self {
        Self { completed: false }
    }
    fn execute(&self, infile: String) {
        let img = image::open(&infile).expect("Failed to open INFILE.");
        let img2 = img.brighten(20);
        img2.save(get_output_dir("brighten", &infile))
            .expect("Failed writing OUTFILE.");
    }
    fn completed(&self) -> bool {
        self.completed
    }
}