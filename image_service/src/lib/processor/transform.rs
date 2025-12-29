pub trait Transform {
    pub fn exec();
}
fn get_output_dir(method: &str, inputfile: &str) -> PathBuf {
    let s = method.to_owned() + "_" + inputfile;
    Path::new(OUTPUT_DIR).join(Path::new(s.as_str()))
}

pub struct Blur {}
impl Blur for Transform {
    fn exec(infile: String) {
        let img = image::open(&infile).expect("Failed to open INFILE.");
        let img2 = img.blur(5.0);
        img2.save(get_output_dir("blur", &infile))
            .expect("Failed writing OUTFILE.");
    }
}

pub struct Brighten {}
impl Brighten for Transform {
    fn exec(infile: String) {
        let img = image::open(&infile).expect("Failed to open INFILE.");
        let img2 = img.brighten(20);
        img2.save(get_output_dir("brighten", &infile))
            .expect("Failed writing OUTFILE.");
    }
}

pub struct Crop {}
impl Crop for Transform {
    fn exec(infile: String) {
        let mut img = image::open(&infile).expect("Failed to open INFILE.");
        let img2 = img.crop(20, 200, 20, 200);
        img2.save(get_output_dir("crop", &infile))
            .expect("Failed writing OUTFILE.");
    }
}

pub struct Rotate {}
impl Rotate for Transform {
    fn exec(infile: String) {
        let img = image::open(&infile).expect("Failed to open INFILE.");
        let img2 = img.rotate180();
        img2.save(get_output_dir("rotate", &infile))
            .expect("Failed writing OUTFILE.");
    }
}

pub struct Invert {}
impl Invert for Transform {
    fn exec(infile: String) {
        let mut img = image::open(&infile).expect("Failed to open INFILE.");
        img.invert();

        img.save(get_output_dir("invert", &infile))
            .expect("Failed writing OUTFILE.");
    }
}

pub struct Fractal {}
impl Fractal for Transform {
    fn exec(infile: String) {
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
}
