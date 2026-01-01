use std::path::PathBuf;

use image::{DynamicImage, ImageBuffer, Rgba};


pub struct Fractal {
    filename: PathBuf,
}

impl Fractal {
    pub fn new(filename: PathBuf) -> Self {
        Self { 
            filename: filename,
        }
    }


    pub fn apply(&self)->DynamicImage{
        let width = 800;
        let height = 800;

        let mut  imgbuf: ImageBuffer<Rgba<u8>, Vec<u8>> =
    ImageBuffer::new(width, height);
        let scale_x = 3.0 / width as f32;
        let scale_y = 3.0 / height as f32;

        for (x, y, pixel) in imgbuf.enumerate_pixels_mut() {
            let red = (0.3 * x as f32) as u8;
            let blue = (0.3 * y as f32) as u8;

            let cx = y as f32 * scale_x - 1.5;
            let cy = x as f32 * scale_y - 1.5;

            let c = num_complex::Complex::new(-0.4, 0.6);
            let mut z = num_complex::Complex::new(cx, cy);

            let mut green = 0;
            while green < 255 && z.norm() <= 2.0 {
                z = z * z + c;
                green += 1;
            }

            *pixel = image::Rgba([red, green, blue,0]);
        }

        DynamicImage::ImageRgba8(imgbuf)
    }
}
