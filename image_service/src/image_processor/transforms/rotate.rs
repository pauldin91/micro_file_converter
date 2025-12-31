use crate::image_processor::transforms::{ transform::get_output_dir};


pub struct Rotate {
    angle: u16, 
}

impl Rotate {
    pub fn new(angle: u16) -> Self {
        Self { 
            angle: angle,
        }
    }
    pub fn apply(&self, infile: String) {
        let img = image::open(&infile).expect("Failed to open INFILE.");
        let img2 = match self.angle {
           90=> img.rotate90(),
           180=> img.rotate180(),
           _ => img.rotate270(),
        };
        img2.save(get_output_dir("rotate", &infile))
            .expect("Failed writing OUTFILE.");
    }

}
