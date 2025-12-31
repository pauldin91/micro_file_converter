use crate::image_processor::transforms::{ transform::get_output_dir};

pub struct Invert {
}
impl Invert {
    pub fn new() -> Self {
        Self {  }
    }

    pub fn apply(&self, infile: String) {
        let mut img = image::open(&infile).expect("Failed to open INFILE.");
        img.invert();

        img.save(get_output_dir("invert", &infile))
            .expect("Failed writing OUTFILE.");
    }

}
