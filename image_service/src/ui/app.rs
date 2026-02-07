use std::collections::HashMap;

use ::image::DynamicImage;
use iced::widget::{button, column, container, image, text};
use iced::{Application, Command, Element, Length, Theme, executor};

use crate::{Controls, Message};
use crate::features::TransformFactory;

pub struct ImageApp {
    // Image state
    original_image: Option<DynamicImage>,
    displayed_image: Option<DynamicImage>,
    image_handle: Option<image::Handle>,
    
    // Transform parameters
    brightness: f32,
    contrast: f32,
    degrees: f32,
    sigma: f32,
    axis: Option<String>,
    invert_enabled: bool,
    
    // Configuration
    instructions: HashMap<String, String>,
    available_axes: Vec<String>,
}

impl Default for ImageApp {
    fn default() -> Self {
        Self {
            original_image: None,
            displayed_image: None,
            image_handle: None,
            brightness: 0.0,
            contrast: 1.0,
            degrees: 0.0,
            sigma: 0.0,
            axis: Some(String::from("none")),
            invert_enabled: false,
            instructions: HashMap::new(),
            available_axes: vec![
                String::from("none"),
                String::from("horizontal"),
                String::from("vertical"),
                String::from("diagonal"),
            ],
        }
    }
}

impl Application for ImageApp {
    type Executor = executor::Default;
    type Message = Message;
    type Theme = Theme;
    type Flags = ();

    fn new(_flags: ()) -> (Self, Command<Message>) {
        (Self::default(), Command::none())
    }

    fn title(&self) -> String {
        "Image Editor - Iced".into()
    }

    fn update(&mut self, message: Message) -> Command<Message> {
        match message {
            Message::SelectImage => {
                Command::perform(
                    async {
                        rfd::FileDialog::new()
                            .add_filter("Images", &["png", "jpg", "jpeg"])
                            .pick_file()
                    },
                    Message::ImageSelected,
                )
            }
            
            Message::SaveImage => {
                Command::perform(
                    async {
                        rfd::FileDialog::new()
                            .add_filter("Images", &["png", "jpg", "jpeg"])
                            .save_file()
                    },
                    Message::ImageSaved,
                )
            }
            
            Message::ImageSaved(path) => {
                if let Some(path) = path {
                    if let Some(img) = &self.displayed_image {
                        let _ = img.save(path);
                    }
                }
                Command::none()
            }
            
            Message::ImageSelected(path) => {
                if let Some(path) = path {
                    if let Ok(img) = ::image::open(&path) {
                        self.load_image(img);
                    }
                }
                Command::none()
            }
            
            Message::BrightnessChanged(brightness) => {
                self.brightness = brightness;
                self.update_instruction("brightness", brightness.to_string());
                self.apply_transform("brighten");
                Command::none()
            }
            
            Message::ContrastChanged(contrast) => {
                self.contrast = contrast;
                self.update_instruction("contrast", contrast.to_string());
                self.apply_transform("brighten");
                Command::none()
            }
            
            Message::RotationChanged(degrees) => {
                self.degrees = degrees;
                self.update_instruction("degrees", degrees.to_string());
                self.apply_transform("rotate");
                Command::none()
            }
            
            Message::InvertToogle => {
                self.invert_enabled = !self.invert_enabled;
                self.apply_transform("invert");
                Command::none()
            }
            
            Message::SigmaChanged(sigma) => {
                self.sigma = sigma;
                self.update_instruction("sigma", sigma.to_string());
                self.apply_transform("blur");
                Command::none()
            }
            
            Message::ReflectionChanged(mirror) => {
                self.axis = Some(mirror.clone());
                self.update_instruction("axis", mirror);
                self.apply_transform("mirror");
                Command::none()
            }
            
            Message::ResetTransforms => {
                self.reset();
                Command::none()
            }
        }
    }

    fn view(&self) -> Element<Message> {
        let image_display = self.build_image_display();
        let controls = self.build_controls();
        let toolbar = self.build_toolbar();

        column![
            toolbar,
            iced::widget::row![
                image_display,
                controls,
            ]
            .spacing(10)
            .height(Length::Fill)
        ]
        .spacing(10)
        .padding(10)
        .width(Length::Fill)
        .height(Length::Fill)
        .into()
    }
}

impl ImageApp {
    /// Load a new image and reset all transforms
    fn load_image(&mut self, img: DynamicImage) {
        self.original_image = Some(img);
        self.displayed_image = self.original_image.clone();
        self.reset();
        self.refresh_image_handle();
    }

    /// Update the image handle from the current displayed image
    fn refresh_image_handle(&mut self) {
        if let Some(img) = &self.displayed_image {
            let rgba = img.to_rgba8();
            let (width, height) = rgba.dimensions();
            self.image_handle = Some(image::Handle::from_pixels(width, height, rgba.into_raw()));
        }
    }

    /// Reset all transforms to default values
    fn reset(&mut self) {
        self.brightness = 0.0;
        self.contrast = 1.0;
        self.degrees = 0.0;
        self.sigma = 0.0;
        self.axis = Some(String::from("none"));
        self.invert_enabled = false;
        self.instructions.clear();
        self.displayed_image = self.original_image.clone();
        self.refresh_image_handle();
    }

    /// Update an instruction in the HashMap
    fn update_instruction(&mut self, key: &str, value: String) {
        self.instructions.insert(key.to_string(), value);
    }

    /// Apply a transform to the current image
    fn apply_transform(&mut self, transform: &str) {
        let original = match &self.displayed_image {
            Some(img) => img,
            None => return,
        };

        let mut current = original.clone();

        if let Ok(kind) = transform.parse::<TransformFactory>() {
            let op = kind.create_from_instructions(&self.instructions);
            if let Ok(transformed) = op.apply(&current) {
                current = transformed;
            }
        }

        self.displayed_image = Some(current);
        self.refresh_image_handle();
    }

    /// Build the image display widget
    fn build_image_display(&self) -> Element<Message> {
        if let Some(handle) = &self.image_handle {
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
            container(text("No image selected. Click 'Open Image' to get started."))
                .width(Length::Fill)
                .height(Length::Fill)
                .center_x()
                .center_y()
                .into()
        }
    }

    /// Build the toolbar with file operations
    fn build_toolbar(&self) -> Element<Message> {
        let save_button = if self.displayed_image.is_some() {
            button("Save Image").on_press(Message::SaveImage)
        } else {
            button("Save Image")
        };

        iced::widget::row![
            button("Open Image").on_press(Message::SelectImage),
            save_button,
        ]
        .spacing(10)
        .into()
    }

    /// Build the controls panel
    fn build_controls(&self) -> Element<Message> {
        if self.displayed_image.is_some() {
            container(
                iced::widget::scrollable(
                    Controls::setup(
                        self.sigma,
                        self.brightness,
                        self.contrast,
                        self.degrees,
                        self.axis.clone(),
                        self.available_axes.clone(),
                    )
                )
            )
            .width(Length::Fixed(320.0))
            .height(Length::Fill)
            .into()
        } else {
            container(column![])
                .width(Length::Fixed(320.0))
                .into()
        }
    }
}