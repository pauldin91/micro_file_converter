use crate::engine::transforms::ImageTransform;


pub struct ImageProcessor {
    transformations: Vec<Box<dyn ImageTransform>>,
}

impl ImageProcessor {
    pub fn new() -> Self {
        Self {
            transformations: Vec::new(),
        }
    }

    pub fn add_transform(&mut self, transform:  Box<dyn ImageTransform>) {
        self.transformations.push(transform);
    }

    pub fn run(&self) {
        for t in &self.transformations {
            let filename = t.filename();
            let _ = t.apply_and_save(filename);
        }
    }
}
