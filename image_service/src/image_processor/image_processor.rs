use crate::image_processor::transforms::Transform;


pub struct ImageProcessor {
    transformations: Vec<Box<dyn Transform>>,
}

impl ImageProcessor {
    pub fn new() -> Self {
        Self {
            transformations: Vec::new(),
        }
    }

    pub fn add_transform(&mut self, transform: Box<dyn Transform>) {
        self.transformations.push(transform);
    }

    pub fn run(&self, infile: String) {
        for t in &self.transformations {
            t.execute(infile.clone());
        }
    }
}
