use crate::Message;
use iced::widget::{button, column, container, pick_list, row, slider, text, Space};
use iced::{Element, Length};

pub struct Controls;

impl Controls {
    pub fn setup<'a>(
        sigma: f32,
        brightness: f32,
        contrast: f32,
        degrees: f32,
        axis: Option<String>,
        axes: Vec<String>,
    ) -> Element<'a, Message> {
        let controls = column![
            // Color & Brightness Section
            Self::section_header("Color"),
            Self::slider_row("Brightness", -5.0..=5.0, brightness, 0.5, Message::BrightnessChanged),
            Self::slider_row("Contrast", 0.0..=3.0, contrast, 0.2, Message::ContrastChanged),
            Self::action_button("Invert", Message::InvertToogle),
            
            Space::with_height(15),
            
            // Effects Section
            Self::section_header("Effects"),
            Self::slider_row("Blur", 0.0..=3.0, sigma, 0.1, Message::SigmaChanged),
            
            Space::with_height(15),
            
            // Transformations Section
            Self::section_header("Transform"),
            Self::rotation_row(degrees),
            Self::mirror_row(axis, axes),
            
            Space::with_height(20),
            
            // Reset button
            Self::reset_button(),
        ]
        .spacing(8)
        .padding(15);

        container(controls)
            .width(Length::Fill)
            .into()
    }

    /// Section header with emoji and styling
    fn section_header(title: &'static str) -> Element<'static, Message> {
        text(title)
            .size(14)
            .into()
    }

    /// Slider control with label, slider, and value display
    fn slider_row<'a, F>(
        label: &'static str,
        range: std::ops::RangeInclusive<f32>,
        value: f32,
        step: f32,
        on_change: F,
    ) -> Element<'a, Message>
    where
        F: 'a + Fn(f32) -> Message,
    {
        column![
            text(label).size(12),
            row![
                slider(range, value, on_change)
                    .step(step)
                    .width(Length::Fill),
                text(Self::format_value(value))
                    .size(11)
                    .width(40),
            ]
            .spacing(8)
            .align_items(iced::Alignment::Center),
        ]
        .spacing(4)
        .into()
    }

    /// Rotation control with degree symbol
    fn rotation_row(degrees: f32) -> Element<'static, Message> {
        column![
            text("Rotation").size(12),
            row![
                slider(0.0..=360.0, degrees, Message::RotationChanged)
                    .step(1.0)
                    .width(Length::Fill),
                text(format!("{:.0}°", degrees))
                    .size(11)
                    .width(40),
            ]
            .spacing(8)
            .align_items(iced::Alignment::Center),
        ]
        .spacing(4)
        .into()
    }

    /// Mirror/flip control with pick list
    fn mirror_row(axis: Option<String>, axes: Vec<String>) -> Element<'static, Message> {
        column![
            text("Mirror").size(12),
            pick_list(axes, axis, Message::ReflectionChanged)
                .width(Length::Fill),
        ]
        .spacing(4)
        .into()
    }

    /// Action button (for Invert)
    fn action_button(label: &'static str, message: Message) -> Element<'static, Message> {
        button(
            text(label)
                .horizontal_alignment(iced::alignment::Horizontal::Center)
                .size(12)
        )
        .on_press(message)
        .width(Length::Fill)
        .into()
    }

    /// Large reset button
    fn reset_button() -> Element<'static, Message> {
        button(
            text("Reset All")
                .horizontal_alignment(iced::alignment::Horizontal::Center)
                .size(12)
        )
        .on_press(Message::ResetTransforms)
        .width(Length::Fill)
        .padding(10)
        .into()
    }

    /// Format numeric value for display
    fn format_value(value: f32) -> String {
        if value.abs() < 0.001 {
            "0.0".to_string()
        } else if value.abs() >= 10.0 {
            format!("{:.0}", value)
        } else {
            format!("{:.1}", value)
        }
    }
}