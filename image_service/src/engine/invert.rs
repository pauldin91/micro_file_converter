use crate::domain::ImageTransform;

pub struct Invert;
impl Invert {
    pub fn new() -> Self {
        Self {}
    }
}
impl ImageTransform for Invert {
    fn apply(&self, img: &[u8]) -> Vec<u8> {
        let mut dynamic_img = image::load_from_memory(img).unwrap();
        dynamic_img.invert();
        Vec::from(dynamic_img.as_bytes())
    }
}
