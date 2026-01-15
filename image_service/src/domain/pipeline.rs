use crate::domain::Transform;


pub struct TransformPipeline {
    transformations: Vec<Box<dyn Transform>>,
}

impl TransformPipeline {
    pub fn new() -> Self {
        Self {
            transformations: Vec::new(),
        }
    }

    pub fn add_transform(&mut self, transform:  Box<dyn Transform>) {
        self.transformations.push(transform);
    }

    pub fn run(&self) {
        for _t in &self.transformations {
            
        }
    }
}
