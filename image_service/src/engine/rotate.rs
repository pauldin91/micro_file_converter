use image::{ImageOutputFormat};
use std::io::Cursor;

use crate::domain::Transform;

pub struct Rotate {
    angle: u16,
}

impl Rotate {
    pub fn new(angle: u16) -> Self {
        Self { angle }
    }
}

impl Transform for Rotate {
    fn apply(&self, img: &[u8]) -> Result<Vec<u8>, image::ImageError> {
        let dynamic_img = image::load_from_memory(img)?;

        let transformed: image::DynamicImage = match self.angle {
            90 => dynamic_img.rotate90(),
            180 => dynamic_img.rotate180(),
            270 => dynamic_img.rotate270(),
            _ => return Err(image::ImageError::Unsupported(
                image::error::UnsupportedError::from_format_and_kind(
                    image::error::ImageFormatHint::Unknown,
                    image::error::UnsupportedErrorKind::GenericFeature(
                        "invalid rotation angle".into(),
                    ),
                ),
            )),
        };

        let mut out = Vec::new();
        transformed.write_to(&mut Cursor::new(&mut out), ImageOutputFormat::Png)?;
        Ok(out)
    }
}
