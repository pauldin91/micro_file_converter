use std::path::{Path, PathBuf};

use crate::image_processor::transforms::{Blur,Brighten,Crop,Fractal,Invert,Rotate};


pub enum Transform{
    Blur(Blur),
    Brighten(Brighten),
    Crop(Crop),
    Fractal(Fractal),
    Invert(Invert),
    Rotate(Rotate),
}


impl Transform{
    pub fn apply(&self,infile:String){
        match self{
            Transform::Blur(t)=>t.apply(infile),
            Transform::Brighten(t)=>t.apply(infile),
            Transform::Crop(t)=>t.apply(infile),
            Transform::Fractal(t)=>t.apply(infile),
            Transform::Invert(t)=>t.apply(infile),
            Transform::Rotate(t)=>t.apply(infile),
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



