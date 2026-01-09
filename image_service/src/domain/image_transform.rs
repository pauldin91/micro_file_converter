
pub trait ImageTransform {
    fn apply(&self,img: &[u8]) -> Vec<u8>;
}