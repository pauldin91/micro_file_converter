use crate::engine::transforms::{ transform::get_output_dir};

pub struct Invert {
    filename: String
}
impl Invert {
    pub fn new(filename: String) -> Self {
        Self { filename: filename }
    }

    pub fn apply(&self) {
        let mut img = image::open(&self.filename).expect("Failed to open INFILE.");
        img.invert();

        img.save(get_output_dir("invert", &self.filename))
            .expect("Failed writing OUTFILE.");
    }

}
