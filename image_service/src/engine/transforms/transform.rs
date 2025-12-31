use std::path::{Path, PathBuf};

use crate::engine::transforms::{Blur,Brighten,Crop,Fractal,Invert,Rotate};


pub enum Transform{
    Blur(Blur),
    Brighten(Brighten),
    Crop(Crop),
    Fractal(Fractal),
    Invert(Invert),
    Rotate(Rotate),
}


impl Transform{
    pub fn apply(&self){
        match self{
            Transform::Blur(t)=>t.apply(),
            Transform::Brighten(t)=>t.apply(),
            Transform::Crop(t)=>t.apply(),
            Transform::Fractal(t)=>t.apply(),
            Transform::Invert(t)=>t.apply(),
            Transform::Rotate(t)=>t.apply(),
        }
    }
    pub fn revert(&self) {

    }
}



pub fn get_output_dir(method: &str, inputfile: &str) -> PathBuf {
    let s = method.to_owned() + "_" + inputfile;
    Path::new(OUTPUT_DIR).join(Path::new(s.as_str()))
}
pub const OUTPUT_DIR: &str = "outputs";



