pub struct ImageProcessor {
    transformations: Vec<Transform>,
}

impl ImageProcessor {
    pub fn add_transform(self, transform: Transform) -> Self {
        self.transformations.add_transform(transform);
    }
}
