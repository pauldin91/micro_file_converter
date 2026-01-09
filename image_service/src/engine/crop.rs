use crate::domain::{ImageTransform, Rect};

pub struct Crop {
    selection: Rect,
}
impl Crop {
    pub fn new(selection: Rect) -> Self {
        Self {
            selection: selection,
        }
    }
}
impl ImageTransform for Crop {
    fn apply(&self, img: &[u8]) -> Vec<u8> {
        let mut dynamic_img=image::load_from_memory(img).unwrap();
            Vec::from(dynamic_img
            .crop(
                self.selection.x,
                self.selection.y,
                self.selection.w,
                self.selection.h,
            )
            .as_bytes())
    }
}
