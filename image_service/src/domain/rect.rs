pub struct Rect {
    pub x: u32,
    pub y: u32,
    pub w: u32,
    pub h: u32,
}

impl Rect {
    pub fn from(rect: &str) -> Self {
        let crop_instructions: Vec<u32> = rect.split(",").map(|s| s.parse().unwrap()).collect();
        Self {
            x: crop_instructions.get(0).unwrap().clone(),
            y: crop_instructions.get(1).unwrap().clone(),
            w: crop_instructions.get(2).unwrap().clone(),
            h: crop_instructions.get(3).unwrap().clone(),
        }
    }
}
