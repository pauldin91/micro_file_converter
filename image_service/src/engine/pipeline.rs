use crate::engine::transforms::Transform;


pub struct ImageProcessor {
    transformations: Vec<Transform>,
}

impl ImageProcessor {
    pub fn new() -> Self {
        Self {
            transformations: Vec::new(),
        }
    }

    pub fn add_transform(&mut self, transform:  Transform) {
        self.transformations.push(transform);
    }

    pub fn run(&self) {
        for t in &self.transformations {
            t.apply();
        }
    }
}
