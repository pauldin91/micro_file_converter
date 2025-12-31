use crate::engine::transforms::{transform::get_output_dir};
use crate::engine::transforms::Rect;
pub struct Crop {
    filename: String,
    selection: Rect,
}
impl Crop{
    pub fn new(filename: String,selection: Rect) -> Self {
        Self { 
            selection: selection, 
            filename: filename,
        }
    }

    pub fn apply(&self) {
        let mut img = image::open(&self.filename).expect("Failed to open INFILE.");
        let img2 = img.crop(self.selection.x,self.selection.y,self.selection.w,self.selection.h);
        img2.save(get_output_dir("crop", &self.filename))
            .expect("Failed writing OUTFILE.");
    }

}