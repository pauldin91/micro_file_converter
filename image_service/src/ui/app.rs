use std::collections::HashMap;

use ::image::DynamicImage;
use iced::widget::{button, column, container, image, pick_list, row, slider, text};
use iced::{Application, Command, Element, Length, Theme, executor};

use crate::Message;
use crate::features::{TransformFactory, decode};

pub struct ImageApp {
    original_image: Option<DynamicImage>,
    image_handle: Option<image::Handle>,
    contrast: f32,
    brightness: i32,
    degrees: f32,
    sigma: f32,
    axis: Option<String>,
    instructions: HashMap<String, String>,
    axes: Vec<String>,
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
                axis: Some(String::from("none")),
                degrees: 0.0,
                contrast: 1.0,
                instructions: HashMap::new(),
                axes: vec![
                    String::from("vertical"),
                    String::from("horizontal"),
                    String::from("diagonal"),
                ],
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
                self.instructions
                    .insert(String::from("brightness"), self.brightness.to_string());
                self.update_transformed_image("brighten");
                Command::none()
            }
            Message::ContrastChanged(constrast) => {
                self.contrast = constrast;
                self.instructions
                    .insert(String::from("contrast"), self.contrast.to_string());
                self.update_transformed_image("contrast");
                Command::none()
            }
            Message::RotationChanged(degrees) => {
                self.degrees = degrees;
                self.instructions
                    .insert(String::from("degrees"), self.degrees.to_string());
                self.update_transformed_image("rotate");
                Command::none()
            }
            Message::SigmaChanged(sigma) => {
                self.sigma = sigma;
                self.instructions
                    .insert(String::from("sigma"), self.sigma.to_string());
                self.update_transformed_image("blur");
                Command::none()
            }
            Message::ReflectionChanged(mirror) => {
                self.axis = Some(mirror);
                let axis = self.axis.clone();
                self.instructions
                    .insert(String::from("axis"), axis.unwrap());
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
                row![
                    text("Mirror:").width(100),
                    pick_list(&self.axes, self.axis.clone(), Message::ReflectionChanged),
                    text(self.axis.as_deref().unwrap_or("None")).width(50),
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
        let original = match &self.original_image {
            Some(img) => img,
            None => return,
        };

        let kind = match transform.parse::<TransformFactory>() {
            Ok(k) => k,
            Err(_) => return,
        };

        let op = kind.create_from_instructions(&self.instructions);

        // Convert DynamicImage to raw RGBA bytes
        let raw_bytes = original.to_rgba8().into_raw();

        let bytes = match op.apply(&raw_bytes) {
            Ok(b) => b,
            Err(_) => return,
        };

        let transformed = match decode(&bytes) {
            Ok(img) => img,
            Err(_) => return,
        };

        let rgba = transformed.to_rgba8();
        let (width, height) = rgba.dimensions();
        self.image_handle = Some(image::Handle::from_pixels(width, height, rgba.into_raw()));
    }
}
