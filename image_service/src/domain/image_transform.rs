use std::path::PathBuf;


pub trait ImageTransform {
    fn apply(&self,img: &[u8])-> Result<Vec<u8>, image::ImageError>;
}