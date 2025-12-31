use std::path::{Path, PathBuf};
pub trait Transform {
    fn apply(&self, infile: String);
    fn revert(&self) -> bool;
}
pub fn get_output_dir(method: &str, inputfile: &str) -> PathBuf {
    let s = method.to_owned() + "_" + inputfile;
    Path::new(OUTPUT_DIR).join(Path::new(s.as_str()))
}
pub const OUTPUT_DIR: &str = "outputs";



