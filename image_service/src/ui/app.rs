use ::image::{DynamicImage, Rgba};
use iced::widget::{button, column, container, image, row, slider, text};
use iced::{Application, Command, Element, Length, Settings, Theme, executor};
use imageproc::geometric_transformations::{Interpolation, rotate_about_center};

use crate::Message;
use crate::features::mirror::MirrorAxis;

pub struct ImageApp {
    original_image: Option<DynamicImage>,
    image_handle: Option<image::Handle>,
    brightness: f32,
    contrast: f32,
    rotation: f32,
    sigma: f32,
    mirror: MirrorAxis,
}

impl Application for ImageApp {
    type Executor = executor::Default;
    type Message = Message;
    type Theme = Theme;
    type Flags = ();

    fn new(_flags: ()) -> (Self, Command<Message>) {
        (
            Self {
                original_image: None,
                image_handle: None,
                brightness: 0.0,
                contrast: 1.0,
                rotation: 0.0,
                sigma: 0.0,
                mirror: MirrorAxis::None,
            },
            Command::none(),
        )
    }

    fn title(&self) -> String {
        "Iced Image Viewer with Transforms".into()
    }

    fn update(&mut self, message: Message) -> Command<Message> {
        match message {
            Message::SelectImage => Command::perform(
                async {
                    rfd::FileDialog::new()
                        .add_filter("Images", &["png", "jpg", "jpeg"])
                        .pick_file()
                },
                Message::ImageSelected,
            ),
            Message::ImageSelected(path) => {
                if let Some(path) = path {
                    if let Ok(img) = ::image::open(&path) {
                        self.original_image = Some(img);
                        self.brightness = 0.0;
                        self.contrast = 1.0;
                        self.rotation = 0.0;
                        self.mirror = MirrorAxis::None;
                        self.sigma = 0.0;
                        self.update_transformed_image();
                    }
                }
                Command::none()
            }
            Message::BrightnessChanged(value) => {
                self.brightness = value;
                self.update_transformed_image();
                Command::none()
            }
            Message::ContrastChanged(value) => {
                self.contrast = value;
                self.update_transformed_image();
                Command::none()
            }
            Message::RotationChanged(value) => {
                self.rotation = value;
                self.update_transformed_image();
                Command::none()
            }
            Message::SigmaChanged(sigma) => {
                self.sigma = sigma;
                self.update_transformed_image();
                Command::none()
            }
            Message::ReflectionChanged(reflection) => {
                self.mirror = reflection;
                self.update_transformed_image();
                Command::none()
            }
            Message::ResetTransforms => {
                self.brightness = 0.0;
                self.contrast = 1.0;
                self.rotation = 0.0;
                self.mirror = MirrorAxis::None;
                self.sigma = 0.0;
                self.update_transformed_image();
                Command::none()
            }
        }
    }

    fn view(&self) -> Element<Message> {
        let image_display: Element<Message> = if let Some(handle) = &self.image_handle {
            container(
                image(handle.clone())
                    .width(Length::Fill)
                    .height(Length::Fill)
                    .content_fit(iced::ContentFit::Contain),
            )
            .width(Length::Fill)
            .height(Length::Fill)
            .center_x()
            .center_y()
            .into()
        } else {
            container(text("No image selected"))
                .width(Length::Fill)
                .height(Length::Fill)
                .center_x()
                .center_y()
                .into()
        };

        let controls = if self.original_image.is_some() {
            column![
                row![
                    text("Brightness:").width(100),
                    slider(-100.0..=100.0, self.brightness, Message::BrightnessChanged).step(1.0),
                    text(format!("{:.0}", self.brightness)).width(50),
                ]
                .spacing(10),
                row![
                    text("Contrast:").width(100),
                    slider(0.0..=3.0, self.contrast, Message::ContrastChanged).step(0.1),
                    text(format!("{:.1}", self.contrast)).width(50),
                ]
                .spacing(10),
                row![
                    text("Rotation:").width(100),
                    slider(0.0..=360.0, self.rotation, Message::RotationChanged).step(1.0),
                    text(format!("{:.0}°", self.rotation)).width(50),
                ]
                .spacing(10),
                button("Reset Transforms").on_press(Message::ResetTransforms),
            ]
            .spacing(10)
        } else {
            column![]
        };

        column![
            button("Select Image").on_press(Message::SelectImage),
            controls,
            image_display,
        ]
        .spacing(20)
        .padding(20)
        .width(Length::Fill)
        .height(Length::Fill)
        .into()
    }
}

impl ImageApp {
    fn update_transformed_image(&mut self) {
        if let Some(original) = &self.original_image {
            let mut transformed = original.clone();

            

            // Convert to bytes and create handle
            let rgba = transformed.to_rgba8();
            let (width, height) = rgba.dimensions();
            let bytes = rgba.into_raw();

            self.image_handle = Some(image::Handle::from_pixels(width, height, bytes));
        }
    }
}
