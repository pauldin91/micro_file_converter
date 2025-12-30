use crate::image_processor::transforms::Transform;



pub struct Fractal {
    completed: bool,
}







impl Transform for Fractal {
    fn new() -> Self {
        Self { completed: false }
    }
    fn completed(&self) -> bool {
        self.completed
    }
    fn execute(&self, outfile: String) {
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
