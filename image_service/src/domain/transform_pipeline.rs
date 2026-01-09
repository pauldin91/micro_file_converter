use crate::domain::ImageTransform;


pub struct TransformPipeline {
    transformations: Vec<Box<dyn ImageTransform>>,
}

impl TransformPipeline {
    pub fn new() -> Self {
        Self {
            transformations: Vec::new(),
        }
    }

    pub fn add_transform(&mut self, transform:  Box<dyn ImageTransform>) {
        self.transformations.push(transform);
    }

    pub fn run(&self) {
        for _t in &self.transformations {
            
        }
    }
}
