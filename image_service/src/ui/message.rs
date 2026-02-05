use std::path::PathBuf;

#[derive(Debug, Clone)]
pub enum Message {
    SelectImage,
    SaveImage,
    ImageSelected(Option<PathBuf>),
    ImageSaved(Option<PathBuf>),
    BrightnessChanged(f32),
    ContrastChanged(f32),
    RotationChanged(f32),
    SigmaChanged(f32),
    ReflectionChanged(String),
    ResetTransforms,
}
