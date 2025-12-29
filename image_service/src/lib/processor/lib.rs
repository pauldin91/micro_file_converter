pub mod image_processor;

pub use image_processor::ImageProcessor;

const OUTPUT_DIR: &'static str = "outputs";

fn configure_command(args: Vec<String>) {
    if args.is_empty() {
        print_usage_and_exit();
    }
    let subcommand = args.remove(0);
    match subcommand.as_str() {
        "blur" => {
            if args.len() != 1 {
                print_usage_and_exit();
            }
            let infile = args.remove(0);
            blur(infile);
        }

        "brighten" => {
            if args.len() != 1 {
                print_usage_and_exit();
            }
            let infile = args.remove(0);
            brighten(infile);
        }

        "crop" => {
            if args.len() != 1 {
                print_usage_and_exit();
            }
            let infile = args.remove(0);
            crop(infile);
        }

        "rotate" => {
            if args.len() != 1 {
                print_usage_and_exit();
            }
            let infile = args.remove(0);
            rotate(infile);
        }

        "invert" => {
            if args.len() != 1 {
                print_usage_and_exit();
            }
            let infile = args.remove(0);
            invert(infile);
        }

        "grayscale" => {
            if args.len() != 1 {
                print_usage_and_exit();
            }
            let infile = args.remove(0);
            grayscale(infile);
        }

        "fractal" => {
            if args.len() != 1 {
                print_usage_and_exit();
            }
            let outfile = args.remove(0);
            fractal(outfile);
        }

        "generate" => {
            if args.len() != 1 {
                print_usage_and_exit();
            }
            let outfile = args.remove(0);
            generate(outfile);
        }

        _ => {
            print_usage_and_exit();
        }
    }
}

use std::path::{Path, PathBuf};

fn print_usage_and_exit() {
    println!("USAGE (when in doubt, use a .png extension on your filenames)");
    println!("blur INFILE OUTFILE");
    println!("fractal OUTFILE");
    std::process::exit(-1);
}



fn brighten(infile: String) {

}

fn crop(infile: String) {

}

fn rotate(infile: String) {

}

fn invert(infile: String) {

}


