use std::{collections::HashMap, str::FromStr};

use image::{DynamicImage, GenericImageView, ImageBuffer, Rgba};

use crate::{
    domain::{ImageError, Instructions},
    features::{Transform, decode, encode},
};
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
        Self {
            axis: MirrorAxis::None,
        }
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
    fn apply(&self, img: &DynamicImage) -> Result<DynamicImage, ImageError> {
        let mut imgbuf: ImageBuffer<Rgba<u8>, Vec<u8>> =
            ImageBuffer::new(img.width(), img.height());
        for (x, y, pixel) in img.pixels() {
            match self.axis {
                MirrorAxis::Vertical => imgbuf.put_pixel(img.width() - x - 1, y, pixel),
                MirrorAxis::Horizontal => imgbuf.put_pixel(x, img.height() - y - 1, pixel),
                MirrorAxis::Diagonal => {
                    imgbuf.put_pixel(img.width() - x - 1, img.height() - y - 1, pixel)
                }
                _ => imgbuf.put_pixel(x, y, pixel),
            }
        }

        let res_img = DynamicImage::ImageRgba8(imgbuf);
        Ok(res_img)
    }
}
