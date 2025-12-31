use crate::engine::transforms::{transform::get_output_dir};
use crate::engine::transforms::Rect;
pub struct Crop {
    selection: Rect,
}
impl Crop{
    pub fn new(selection: Rect) -> Self {
        Self { 
            selection: selection, 
        }
    }

    pub fn apply(&self, infile: String) {
        let mut img = image::open(&infile).expect("Failed to open INFILE.");
        let img2 = img.crop(self.selection.x,self.selection.y,self.selection.w,self.selection.h);
        img2.save(get_output_dir("crop", &infile))
            .expect("Failed writing OUTFILE.");
    }

}