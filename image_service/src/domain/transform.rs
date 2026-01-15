
pub trait Transform {
    fn apply(&self,img: &[u8])-> Result<Vec<u8>, image::ImageError>;
}