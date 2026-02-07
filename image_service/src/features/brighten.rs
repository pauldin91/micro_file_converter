use std::collections::HashMap;


use image::DynamicImage;

use crate::{domain::{ImageError, Instructions}, features::Transform};

pub struct Brighten {
    contrast: f32,
    brightness: f32,
}

impl Brighten {
    pub fn new() -> Self {
        Self {
            contrast: 0.0,
            brightness: 0.0
        }
    }
    pub fn from(props: &HashMap<String, String>) -> Self {
        
        let contrast: f32 = Instructions::parse_properties::<f32>(props, "contrast").unwrap_or(1.0);

        let brightness: f32 = Instructions::parse_properties::<f32>(props, "brightness").unwrap_or(0.0);
       
       Self { contrast, brightness: brightness }
    }
}
impl Transform for Brighten {
    fn apply(&self, img: &DynamicImage) -> Result<DynamicImage, ImageError> {
                let mut rgba = img.to_rgba8();
        let (width, height) = rgba.dimensions();

        for y in 0..height {
            for x in 0..width {
                let pixel = rgba.get_pixel_mut(x, y);
                let r = pixel[0] as f32;
                let g = pixel[1] as f32;
                let b = pixel[2] as f32;

                // Apply contrast and brightness
                let new_r = ((r - 128.0) * self.contrast + 128.0 + self.brightness).clamp(0.0, 255.0);
                let new_g = ((g - 128.0) * self.contrast + 128.0 + self.brightness).clamp(0.0, 255.0);
                let new_b = ((b - 128.0) * self.contrast + 128.0 + self.brightness).clamp(0.0, 255.0);

                pixel[0] = new_r as u8;
                pixel[1] = new_g as u8;
                pixel[2] = new_b as u8;
            }
        }

        Ok(DynamicImage::ImageRgba8(rgba))
    
    }
}
