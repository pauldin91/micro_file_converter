use crate::domain::ImageTransform;

pub struct Brighten;
impl Brighten {
    pub fn new() -> Self {
    Self
    }

}
impl ImageTransform for Brighten {

    fn apply(&self,img: &[u8]) -> Vec<u8> {
        let dynamic_img = image::load_from_memory(img).unwrap(); 
        Vec::from(dynamic_img.brighten(20).as_bytes())
    }
}
