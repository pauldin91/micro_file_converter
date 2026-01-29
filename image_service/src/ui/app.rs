use iced::widget::{button, column, container, image, row, slider, text};
use iced::{executor, Application, Command, Element, Length, Settings, Theme};
use ::image::{DynamicImage, Rgba};
use imageproc::geometric_transformations::{rotate_about_center, Interpolation};

use crate::Message;


pub struct ImageApp {
    original_image: Option<DynamicImage>,
    image_handle: Option<image::Handle>,
    brightness: f32,
    contrast: f32,
    rotation: f32,
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
            Message::ResetTransforms => {
                self.brightness = 0.0;
                self.contrast = 1.0;
                self.rotation = 0.0;
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
                    slider(-100.0..=100.0, self.brightness, Message::BrightnessChanged)
                        .step(1.0),
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

            // Apply brightness and contrast
            transformed = self.apply_brightness_contrast(transformed);

            // Apply rotation (arbitrary angle)
            if self.rotation != 0.0 {
                transformed = self.apply_rotation(transformed);
            }

            // Convert to bytes and create handle
            let rgba = transformed.to_rgba8();
            let (width, height) = rgba.dimensions();
            let bytes = rgba.into_raw();

            self.image_handle = Some(image::Handle::from_pixels(width, height, bytes));
        }
    }

    fn apply_brightness_contrast(&self, img: DynamicImage) -> DynamicImage {
        let mut rgba = img.to_rgba8();
        let (width, height) = rgba.dimensions();

        for y in 0..height {
            for x in 0..width {
                let pixel = rgba.get_pixel_mut(x, y);
                let r = pixel[0] as f32;
                let g = pixel[1] as f32;
                let b = pixel[2] as f32;

                // Apply contrast and brightness
                let new_r = ((r - 128.0) * self.contrast + 128.0 + self.brightness).clamp(0.0, 255.0);
                let new_g = ((g - 128.0) * self.contrast + 128.0 + self.brightness).clamp(0.0, 255.0);
                let new_b = ((b - 128.0) * self.contrast + 128.0 + self.brightness).clamp(0.0, 255.0);

                pixel[0] = new_r as u8;
                pixel[1] = new_g as u8;
                pixel[2] = new_b as u8;
            }
        }

        DynamicImage::ImageRgba8(rgba)
    }

    fn apply_rotation(&self, img: DynamicImage) -> DynamicImage {
        let rgba = img.to_rgba8();
        
        // Convert degrees to radians (imageproc uses radians)
        let angle_radians = -self.rotation.to_radians(); // Negative for clockwise rotation
        
        // Define the background color (transparent or white)
        let background = Rgba([255u8, 255u8, 255u8, 0u8]); // Transparent white
        
        // Rotate the image around its center with bilinear interpolation
        let rotated = rotate_about_center(
            &rgba,
            angle_radians,
            Interpolation::Bilinear,
            background,
        );
        
        DynamicImage::ImageRgba8(rotated)
    }
}