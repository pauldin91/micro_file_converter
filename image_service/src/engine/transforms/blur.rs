use crate::engine::transforms::{ transform::get_output_dir};

pub struct Blur {
    sigma: f32,
    filename: String,
}

impl Blur {
    pub fn new(filename: String,sigma: f32) -> Self {
        Self {
            filename: filename,
            sigma: sigma,
        }
    }

    pub fn apply(&self) {
        let img = image::open(&self.filename).expect("Failed to open INFILE.");
        let img2 = img.blur(self.sigma);
        img2.save(get_output_dir("blur", &self.filename))
            .expect("Failed writing OUTFILE.");
    }

}
