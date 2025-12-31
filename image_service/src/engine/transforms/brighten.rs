use crate::engine::transforms::{ transform::get_output_dir};

pub struct Brighten {
    filename: String,
}
impl Brighten {
    pub fn new(filename: String) -> Self {
        Self {  
            filename: filename,
        }
    }
    pub fn apply(&self) {
        let img = image::open(&self.filename).expect("Failed to open INFILE.");
        let img2 = img.brighten(20);
        img2.save(get_output_dir("brighten", &self.filename))
            .expect("Failed writing OUTFILE.");
    }

}
