use crate::domain::ImageTransform;
pub struct Rotate {
    angle: u16,
}

impl Rotate {
    pub fn new( angle: u16) -> Self {
        Self {
            angle: angle,
        }
    }
}
impl ImageTransform for Rotate{


    fn apply(&self,img: &[u8]) -> Vec<u8> {
        let dynamic_img = image::load_from_memory(img).unwrap();
        let img2 = match self.angle {
            90 => dynamic_img.rotate90(),
            180 => dynamic_img.rotate180(),
            _ => dynamic_img.rotate270(),
        };
        Vec::from(img2.as_bytes())
    }
}
