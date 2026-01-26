use crate::domain::error::ImageError;

pub trait Generator{
    fn generate(&self) -> Result<Vec<u8>, ImageError>;
}