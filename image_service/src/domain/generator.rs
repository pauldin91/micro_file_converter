pub trait Generator{
    fn generate(&self) -> Result<Vec<u8>, image::ImageError>;
}