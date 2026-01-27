use clap::{Arg, Command, value_parser};
use image_service::{Fractal, domain::Generator, adapters::LocalStorage, ports::Storage};
use std::{fs, path::PathBuf};

fn main() {
    let matches = Command::new("fractal-cli")
        .version("0.1.0")
        .arg(
            Arg::new("width")
                .long("width")
                .value_parser(value_parser!(u32))
                .help("img width in px"),
        )
        .arg(
            Arg::new("height")
                .long("height")
                .value_parser(value_parser!(u32))
                .help("img height in px"),
        )
        .arg(
            Arg::new("scale")
                .long("scale")
                .value_parser(value_parser!(f32))
                .help("Scale of fractal"),
        )
        .arg(Arg::new("output").long("output").help("results directory"))
        .get_matches();

    let width: u32 = matches.get_one::<u32>("width").unwrap_or(&480).clone();
    let height: u32 = matches.get_one::<u32>("height").unwrap_or(&480).clone();
    let scale: f32 = matches.get_one::<f32>("scale").unwrap_or(&2.0).clone();
    let dir: String = matches
        .get_one::<String>("output")
        .unwrap_or(&String::from("test"))
        .clone();

    let storage = Box::new(LocalStorage::new());
    let fractal = Fractal::new(width, height, scale);
    let img_res = fractal.generate();

    match img_res {
        Ok(img) => {
            let base_dir = PathBuf::from("../uploads").join(dir);
            let _ = fs::create_dir(&base_dir);
            let filename = base_dir
                .clone()
                .join(format!("fractal_{}x{}_{}s.png", width, height, scale));
            storage.save(&filename, &img);
        }
        Err(e) => eprintln!("{}", e),
    }
}
