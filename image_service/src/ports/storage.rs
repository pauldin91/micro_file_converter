use std::{io, path::{Path, PathBuf}};

pub trait Storage: Send + Sync {
    fn save(&self,filename: &Path,content: &[u8]);
    fn get_transformed_filename(&self,old_filename: &str,transform_type: &str) -> PathBuf;
    fn load(&self,fullpath: &str)-> io::Result<Vec<u8>>;
    fn list_dir(&self,dir: &str)->Vec<String>;
}