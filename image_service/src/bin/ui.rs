use iced::{Application, Settings};
use image_service::ImageApp;

fn main() -> iced::Result {
    ImageApp::run(Settings::default())
}
