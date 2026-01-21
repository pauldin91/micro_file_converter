use iced::widget::{button, column, image, text};
use iced::{executor, Application, Command, Element, Settings, Theme};
use std::path::PathBuf;

fn main() -> iced::Result {
    ImageApp::run(Settings::default())
}

struct ImageApp {
    image_path: Option<PathBuf>,
}

#[derive(Debug, Clone)]
enum Message {
    SelectImage,
    ImageSelected(Option<PathBuf>),
}

impl Application for ImageApp {
    type Executor = executor::Default;
    type Message = Message;
    type Theme = Theme;
    type Flags = ();

    fn new(_flags: ()) -> (Self, Command<Message>) {
        (
            Self {
                image_path: None,
            },
            Command::none(),
        )
    }

    fn title(&self) -> String {
        "Iced Image Viewer".into()
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

            Message::ImageSelected(path) => {
                self.image_path = path;
                Command::none()
            }
        }
    }

    fn view(&self) -> Element<Message> {
        let content: Element<Message> = match &self.image_path {
            Some(path) => image(path.clone())
                .width(400)
                .into(),
            None => text("No image selected").into(),
        };

        column![
            button("Select Image").on_press(Message::SelectImage),
            content,
        ]
        .spacing(20)
        .padding(20)
        .into()
    }
}
