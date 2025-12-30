use crate::image_processor::transforms::{Transform, transform::get_output_dir};

pub struct Blur {
    completed: bool,
}

impl Transform for Blur {
    fn new() -> Self {
        Self { completed: false }
    }

    fn execute(&self, infile: String) {
        let img = image::open(&infile).expect("Failed to open INFILE.");
        let img2 = img.blur(5.0);
        img2.save(get_output_dir("blur", &infile))
            .expect("Failed writing OUTFILE.");
    }
    fn completed(&self) -> bool {
        self.completed
    }
}