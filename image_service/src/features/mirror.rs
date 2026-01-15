use std::io::Cursor;

use image::{DynamicImage, GenericImageView, ImageBuffer, ImageOutputFormat, Rgba};

use crate::domain::Transform;

pub enum MirrorAxis{
    Vertical,
    Horizontal,
    Diagonal
}

pub struct Mirror;
impl Mirror {
    pub fn new() -> Self {
        Self {}
    }
}


impl Transform for Mirror{
    fn apply(&self,img: &[u8])-> Result<Vec<u8>, image::ImageError> {
        let dynamic_img = image::load_from_memory(img).unwrap();


        let mut imgbuf: ImageBuffer<Rgba<u8>, Vec<u8>> = ImageBuffer::new(dynamic_img.width(), dynamic_img.height());
        for (x, y, pixel) in dynamic_img.pixels() {
            imgbuf.put_pixel(dynamic_img.width()- x-1,y, pixel);
        }

        let img = DynamicImage::ImageRgba8(imgbuf);
        let mut out = Vec::new();
        img.write_to(&mut Cursor::new(&mut out), ImageOutputFormat::Jpeg(100))?;
        Ok(out)
    }
}