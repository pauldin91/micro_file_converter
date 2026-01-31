use std::path::PathBuf;

use crate::features::mirror::MirrorAxis;

#[derive(Debug, Clone)]
pub enum Message {
    SelectImage,
    ImageSelected(Option<PathBuf>),
    BrightnessChanged(f32),
    ContrastChanged(f32),
    RotationChanged(f32),
    ReflectionChanged(MirrorAxis),
    SigmaChanged(f32),
    ResetTransforms,
}