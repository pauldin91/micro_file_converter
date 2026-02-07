
use crate::{Message};
use iced::widget::{button, column, pick_list, row, slider, text};

pub struct Controls{}

impl Controls{
    pub fn setup<'a>(sigma: f32,brightness:f32,contrast:f32,degrees:f32,axis: Option<String>,axes: Vec<String>) -> iced::widget::Column<'a, Message>{
        column![
                row![
                    text("Blur:").width(100),
                    slider(0.0..=3.0, sigma, Message::SigmaChanged).step(0.1),
                    text(format!("{:.1}", sigma)).width(50),
                ]
                .spacing(10),
                row![
                    text("Brightness:").width(100),
                    slider(-5.0..=5.0, brightness, Message::BrightnessChanged).step(0.5),
                    text(format!("{:.0}", brightness)).width(50),
                ]
                .spacing(10),
                row![
                    text("Contrast:").width(100),
                    slider(0.0..=3.0, contrast, Message::ContrastChanged).step(0.2),
                    text(format!("{:.1}", contrast)).width(50),
                ]
                .spacing(10),
                row![button("Invert").on_press(Message::InvertToogle)].spacing(10),
                row![
                    text("Mirror:").width(100),
                    pick_list(axes, axis.clone(), Message::ReflectionChanged),
                    text(axis.as_deref().unwrap_or("None")).width(50),
                ]
                .spacing(10),
                row![
                    text("Rotation:").width(100),
                    slider(0.0..=360.0, degrees, Message::RotationChanged).step(1.0),
                    text(format!("{:.0}°", degrees)).width(50),
                ]
                .spacing(10),
                button("Reset Transforms").on_press(Message::ResetTransforms),
            ]
            .spacing(10)
    }
}