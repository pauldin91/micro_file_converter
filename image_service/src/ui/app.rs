use std::collections::HashMap;

use ::image::DynamicImage;
use iced::widget::{button, column, container, image, row, slider, text};
use iced::{Application, Command, Element, Length, Theme, executor};

use crate::Message;
use crate::domain::Transform;
use crate::features::TransformFactory;
use crate::features::mirror::MirrorAxis;

pub struct ImageApp {
    original_image: Option<DynamicImage>,
    image_handle: Option<image::Handle>,
    contrast: f32,
    brightness: i32,
    degrees: f32,
    sigma: f32,
    axis: String,
    instructions: HashMap<String, String>,
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
                brightness: 0,
                sigma: 0.0,
                axis: String::from("none"),
                degrees: 0.0,
                contrast: 1.0,
                instructions: HashMap::new()
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
                        self.init();
                    }
                }
                Command::none()
            }
            Message::BrightnessChanged(brightness) => {
                self.brightness = brightness;
                self.instructions.insert(String::from("brightness"), self.brightness.to_string());
                self.update_transformed_image("brighten");
                Command::none()
            }
            Message::ContrastChanged(constrast) => {
                self.contrast = constrast;
                self.instructions.insert(String::from("contrast"), self.contrast.to_string());
                self.update_transformed_image("contrast");
                Command::none()
            }
            Message::RotationChanged(degrees) => {
                self.degrees = degrees;
                self.instructions.insert(String::from("degrees"), self.degrees.to_string());
                self.update_transformed_image("rotate");
                Command::none()
            }
            Message::SigmaChanged(sigma) => {
                self.sigma = sigma;
                self.instructions.insert(String::from("sigma"), self.sigma.to_string());
                self.update_transformed_image("blur");
                Command::none()
            }
            Message::ReflectionChanged(mirror) => {
                self.axis = mirror;
                self.instructions.insert(String::from("axis"), self.axis.to_string());
                self.update_transformed_image("mirror");
                Command::none()
            }
            Message::ResetTransforms => {
                self.reset();
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
                    slider(-100..=100, self.brightness, Message::BrightnessChanged).step(1),
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
                    slider(0.0..=360.0, self.degrees, Message::RotationChanged).step(1.0),
                    text(format!("{:.0}°", self.degrees)).width(50),
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
    fn init(&self) {}
    fn reset(&self) {}
    fn update_transformed_image(&mut self, transform: &str) {
        if let Some(original) = &self.original_image {
            let temp = original.clone();
            match transform.parse::<TransformFactory>() {
                Ok(kind) => {
                    let op: Box<dyn Transform> = kind.create_from_instructions(&self.instructions);

                    let result = op.apply(&temp.as_bytes());
                    match result {
                        Ok(bytes) => {
                            let transormed = ::image::load_from_memory(bytes.as_slice()).unwrap();
                            let rgba = transormed.to_rgba8();
                            let (width, height) = rgba.dimensions();
                            let bytes = rgba.into_raw();

                            self.image_handle =
                                Some(image::Handle::from_pixels(width, height, bytes));
                        }
                        Err(_) => (),
                    }
                }
                Err(_) => (),
            }
        }
    }
}
