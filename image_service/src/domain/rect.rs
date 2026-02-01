pub struct Rect {
    pub x: u32,
    pub y: u32,
    pub w: u32,
    pub h: u32,
}

impl Rect {
    pub fn new(x: u32, y: u32, width: u32, height: u32) -> Self {
        Self {
            x,
            y,
            w: width,
            h: height,
        }
    }
    pub fn from(rect: &str) -> Self {
        let crop_instructions: Vec<u32> = rect.split(",").map(|s| s.parse().unwrap()).collect();
        Self {
            x: *crop_instructions.first().unwrap(),
            y: *crop_instructions.get(1).unwrap(),
            w: *crop_instructions.get(2).unwrap(),
            h: *crop_instructions.get(3).unwrap(),
        }
    }
}
