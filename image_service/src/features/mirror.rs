use std::{collections::HashMap, str::FromStr};

use image::{DynamicImage, GenericImageView, ImageBuffer, Rgba};

use crate::{domain::{ImageError, Instructions, Transform}, features::{decode, encode}};
#[derive(Debug, Copy, Clone)]
pub enum MirrorAxis {
    None,
    Vertical,
    Horizontal,
    Diagonal,
}

impl FromStr for MirrorAxis {
    type Err = ();

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "vertical" => Ok(Self::Vertical),
            "horizontal" => Ok(Self::Horizontal),
            "diagonal" => Ok(Self::Diagonal),
            _ => Ok(Self::None),
        }
    }
}
pub struct Mirror {
    axis: MirrorAxis,
}
impl Default for Mirror {
    fn default() -> Self {
        Self::new()
    }
}

impl Mirror {
    pub fn new() -> Self {
        Self { axis: MirrorAxis::None }
    }
    pub fn from(props: &HashMap<String, String>) -> Self {
        let axis_key = Instructions::parse_properties::<String>(props, "axis");
        let axis = match axis_key {
            Some(axis_type) => match axis_type.parse::<MirrorAxis>() {
                Ok(axis) => axis,
                Err(_) => MirrorAxis::Vertical,
            },
            None => MirrorAxis::Vertical,
        };

        Self { axis }
    }
}

impl Transform for Mirror {
    fn apply(&self, img: &[u8]) -> Result<Vec<u8>, ImageError> {
        let dynamic_img = decode(img)?;

        let mut imgbuf: ImageBuffer<Rgba<u8>, Vec<u8>> =
            ImageBuffer::new(dynamic_img.width(), dynamic_img.height());
        for (x, y, pixel) in dynamic_img.pixels() {
            match self.axis {
                MirrorAxis::Vertical => imgbuf.put_pixel(dynamic_img.width() - x - 1, y, pixel),
                MirrorAxis::Horizontal => imgbuf.put_pixel(x, dynamic_img.height() - y - 1, pixel),
                MirrorAxis::Diagonal => imgbuf.put_pixel(
                    dynamic_img.width() - x - 1,
                    dynamic_img.height() - y - 1,
                    pixel,
                ),
                _ => imgbuf.put_pixel(x, y, pixel),
            }
        }

        let img = DynamicImage::ImageRgba8(imgbuf);
        encode(&img)
    }
}
