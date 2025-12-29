use std::path::{Path,PathBuf};

pub trait Transform {
    fn exec(&self,infile: String);
}
pub const OUTPUT_DIR: &str = "outputs";
pub struct Blur;
pub struct Brighten;
pub struct Crop;
pub struct Rotate;
pub struct Invert;
pub struct Fractal;

fn get_output_dir(method: &str, inputfile: &str) -> PathBuf {
    let s = method.to_owned() + "_" + inputfile;
    Path::new(OUTPUT_DIR).join(Path::new(s.as_str()))
}

impl Transform for Blur {
    fn exec(&self,infile: String) {
        let img = image::open(&infile).expect("Failed to open INFILE.");
        let img2 = img.blur(5.0);
        img2.save(get_output_dir("blur", &infile))
            .expect("Failed writing OUTFILE.");
    }
}

impl Transform for Brighten {
    fn exec(&self,infile: String) {
        let img = image::open(&infile).expect("Failed to open INFILE.");
        let img2 = img.brighten(20);
        img2.save(get_output_dir("brighten", &infile))
            .expect("Failed writing OUTFILE.");
    }
}

impl Transform for Crop {
    fn exec(&self,infile: String) {
        let mut img = image::open(&infile).expect("Failed to open INFILE.");
        let img2 = img.crop(20, 200, 20, 200);
        img2.save(get_output_dir("crop", &infile))
            .expect("Failed writing OUTFILE.");
    }
}

impl Transform  for Rotate {
    fn exec(&self,infile: String) {
        let img = image::open(&infile).expect("Failed to open INFILE.");
        let img2 = img.rotate180();
        img2.save(get_output_dir("rotate", &infile))
            .expect("Failed writing OUTFILE.");
    }
}

impl Transform  for Invert {
    fn exec(&self,infile: String) {
        let mut img = image::open(&infile).expect("Failed to open INFILE.");
        img.invert();

        img.save(get_output_dir("invert", &infile))
            .expect("Failed writing OUTFILE.");
    }
}

impl Transform  for Fractal {
    fn exec(&self,outfile: String) {
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
