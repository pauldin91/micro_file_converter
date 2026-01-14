use image::{DynamicImage, ImageBuffer, ImageOutputFormat, Rgba};
use std::io::Cursor;

pub struct Fractal {
    width: u32,
    height: u32,
    scale: f32,
}

impl Fractal {
    pub fn new(width: u32, height: u32,scale:f32) -> Self {
        Self { width, height,scale }
    }
}
impl Fractal {
    pub fn apply(&self) -> Result<Vec<u8>, image::ImageError> {

        let mut imgbuf: ImageBuffer<Rgba<u8>, Vec<u8>> = ImageBuffer::new(self.width, self.height);


        let scale_x = self.scale / self.width as f32;
        let scale_y = self.scale / self.height as f32;

        for (x, y, pixel) in imgbuf.enumerate_pixels_mut() {
            let red = (0.3 * x as f32) as u8;
            let blue = (0.3 * y as f32) as u8;

            let cx = y as f32 * scale_x - (self.scale/2.0 as f32);
            let cy = x as f32 * scale_y - (self.scale/2.0 as f32);

            let c = num_complex::Complex::new(-0.4, 0.6);
            let mut z = num_complex::Complex::new(cx, cy);

            let mut green = 0;
            while green < 255 && z.norm() <= 2.0 {
                z = z * z + c;
                green += 1;
            }

            *pixel = image::Rgba([red, green, blue, 0]);
        }

        let dynamic_img = DynamicImage::ImageRgba8(imgbuf);
        let mut out = Vec::new();
        dynamic_img.write_to(&mut Cursor::new(&mut out), ImageOutputFormat::Jpeg(100))?;
        Ok(out)
    }
}
