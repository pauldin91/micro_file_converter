use crate::image_processor::transforms::{Transform, transform::get_output_dir};
use crate::image_processor::transforms::Rect;
pub struct Crop {
    completed: bool,
    selection: Rect,
}
impl Crop{
    pub fn new(selection: Rect) -> Self {
        Self { 
            completed: false,
            selection: selection, 
        }
    }
}
impl Transform for Crop {

    fn apply(&self, infile: String) {
        let mut img = image::open(&infile).expect("Failed to open INFILE.");
        let img2 = img.crop(self.selection.x,self.selection.y,self.selection.w,self.selection.h);
        img2.save(get_output_dir("crop", &infile))
            .expect("Failed writing OUTFILE.");
    }
    fn revert(&self) -> bool {
        self.completed
    }
}