use std::{io::Cursor, str::FromStr};

use image::{DynamicImage, GenericImageView, ImageBuffer, ImageOutputFormat, Rgba};

use crate::domain::Transform;

pub enum MirrorAxis {
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
            _ => Err(()),
        }
    }
}
pub struct Mirror {
    axis: MirrorAxis,
}
impl Mirror {
    pub fn new(axis: String) -> Self {
        Self {
            axis: axis
                .parse::<MirrorAxis>()
                .unwrap_or_else(|_| MirrorAxis::Vertical),
        }
    }
}

impl Transform for Mirror {
    fn apply(&self, img: &[u8]) -> Result<Vec<u8>, image::ImageError> {
        let dynamic_img = image::load_from_memory(img).unwrap();

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
            }
        }

        let img = DynamicImage::ImageRgba8(imgbuf);
        let mut out = Vec::new();
        img.write_to(&mut Cursor::new(&mut out), ImageOutputFormat::Jpeg(100))?;
        Ok(out)
    }
}
