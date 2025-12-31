use crate::image_processor::transforms::{Transform, transform::get_output_dir};

pub struct Brighten {
    completed: bool,
}
impl Brighten {
    pub fn new() -> Self {
        Self { completed: false }
    }
}
impl Transform for Brighten {
    fn apply(&self, infile: String) {
        let img = image::open(&infile).expect("Failed to open INFILE.");
        let img2 = img.brighten(20);
        img2.save(get_output_dir("brighten", &infile))
            .expect("Failed writing OUTFILE.");
    }
    fn revert(&self) -> bool {
        self.completed
    }
}
