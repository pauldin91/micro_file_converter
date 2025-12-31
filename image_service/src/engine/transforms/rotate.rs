use crate::engine::transforms::{ transform::get_output_dir};


pub struct Rotate {
    filename: String,
    angle: u16, 
}

impl Rotate {
    pub fn new(filename: String,angle: u16) -> Self {
        Self { 
            angle: angle,
            filename: filename,
        }
    }
    pub fn apply(&self) {
        let img = image::open(&self.filename).expect("Failed to open INFILE.");
        let img2 = match self.angle {
           90=> img.rotate90(),
           180=> img.rotate180(),
           _ => img.rotate270(),
        };
        img2.save(get_output_dir("rotate", &self.filename))
            .expect("Failed writing OUTFILE.");
    }

}
