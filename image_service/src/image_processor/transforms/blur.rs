use crate::image_processor::transforms::{ transform::get_output_dir};

pub struct Blur {
    sigma: f32,
}

impl Blur {
    pub fn new(sigma: f32) -> Self {
        Self {
            sigma: sigma,
        }
    }

    pub fn apply(&self, infile: String) {
        let img = image::open(&infile).expect("Failed to open INFILE.");
        let img2 = img.blur(self.sigma);
        img2.save(get_output_dir("blur", &infile))
            .expect("Failed writing OUTFILE.");
    }

}
