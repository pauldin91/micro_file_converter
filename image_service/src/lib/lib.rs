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

fn blur(infile: String) {
    let img = image::open(&infile).expect("Failed to open INFILE.");
    let img2 = img.blur(5.0);
    img2.save(get_output_dir("invert", &infile))
        .expect("Failed writing OUTFILE.");
}

fn brighten(infile: String) {
    let img = image::open(&infile).expect("Failed to open INFILE.");
    let img2 = img.brighten(20);
    img2.save(get_output_dir("invert", &infile))
        .expect("Failed writing OUTFILE.");
}

fn crop(infile: String) {
    let mut img = image::open(&infile).expect("Failed to open INFILE.");
    let img2 = img.crop(20, 200, 20, 200);
    img2.save(get_output_dir("invert", &infile))
        .expect("Failed writing OUTFILE.");
}

fn rotate(infile: String) {
    let img = image::open(&infile).expect("Failed to open INFILE.");
    let img2 = img.rotate180();
    img2.save(get_output_dir("invert", &infile))
        .expect("Failed writing OUTFILE.");
}

fn invert(infile: String) {
    let mut img = image::open(&infile).expect("Failed to open INFILE.");
    img.invert();

    img.save(get_output_dir("invert", &infile))
        .expect("Failed writing OUTFILE.");
}

fn get_output_dir(method: &str, inputfile: &str) -> PathBuf {
    let s = method.to_owned() + "_" + inputfile;
    Path::new(OUTPUT_DIR).join(Path::new(s.as_str()))
}

fn grayscale(infile: String) {
    let img = image::open(&infile).expect("Failed to open INFILE.");
    let img2 = img.grayscale();
    img2.save(get_output_dir("invert", &infile))
        .expect("Failed writing OUTFILE.");
}

fn generate(outfile: String) {}

fn fractal(outfile: String) {
    let width = 800;
    let height = 800;

    let mut imgbuf = image::ImageBuffer::new(width, height);

    let scale_x = 3.0 / width as f32;
    let scale_y = 3.0 / height as f32;

    for (x, y, pixel) in imgbuf.enumerate_pixels_mut() {
        let red = (0.3 * x as f32) as u8;
        let blue = (0.3 * y as f32) as u8;

        let cx = y as f32 * scale_x - 1.5;
        let cy = x as f32 * scale_y - 1.5;

        let c = num_complex::Complex::new(-0.4, 0.6);
        let mut z = num_complex::Complex::new(cx, cy);

        let mut green = 0;
        while green < 255 && z.norm() <= 2.0 {
            z = z * z + c;
            green += 1;
        }

        *pixel = image::Rgb([red, green, blue]);
    }

    imgbuf.save(outfile).unwrap();
}
