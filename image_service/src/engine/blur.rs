
use crate::{domain::ImageTransform};

pub struct Blur {
    sigma: f32,
}

impl Blur {
    pub fn new(sigma: f32) -> Self {
        Self {
            sigma: sigma,
        }
    }

}
impl ImageTransform for Blur{

    fn apply(&self,img: &[u8]) -> Vec<u8> {
        let dynamic_img = image::load_from_memory(img).unwrap();
        Vec::from(dynamic_img.blur(self.sigma).as_bytes())
    }
}
