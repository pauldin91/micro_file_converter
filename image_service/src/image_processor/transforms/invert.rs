use crate::image_processor::transforms::{Transform, transform::get_output_dir};


pub struct Invert {
    completed: bool,
}
impl Transform for Invert {
    fn new() -> Self {
        Self { completed: false }
    }
    fn execute(&self, infile: String) {
        let mut img = image::open(&infile).expect("Failed to open INFILE.");
        img.invert();

        img.save(get_output_dir("invert", &infile))
            .expect("Failed writing OUTFILE.");
    }
    fn completed(&self) -> bool {
        self.completed
    }
}
