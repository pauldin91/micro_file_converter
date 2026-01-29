use std::path::PathBuf;

#[derive(Debug, Clone)]
pub enum Message {
    SelectImage,
    ImageSelected(Option<PathBuf>),
    BrightnessChanged(f32),
    ContrastChanged(f32),
    RotationChanged(f32),
    ResetTransforms,
}