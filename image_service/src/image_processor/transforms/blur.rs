use crate::image_processor::transforms::{Transform, transform::get_output_dir};

pub struct Blur {
    completed: bool,
    sigma: f32,
}

impl Blur {
    pub fn new(sigma:f32) -> Self {
        Self { completed: false,
        sigma: sigma, 
    }
    }

}
impl Transform for Blur {

    fn apply(&self, infile: String) {
        let img = image::open(&infile).expect("Failed to open INFILE.");
        let img2 = img.blur(self.sigma);
        img2.save(get_output_dir("blur", &infile))
            .expect("Failed writing OUTFILE.");
    }
    fn revert(&self) -> bool {
        self.completed
    }
}