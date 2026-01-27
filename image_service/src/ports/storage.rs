use std::{io, path::{PathBuf}};

pub trait Storage: Send + Sync {
    fn save(&self,filename: &PathBuf,content: &Vec<u8>);
    fn get_transformed_filename(&self,old_filename: &String,transform_type: &String) -> PathBuf;
    fn load(&self,fullpath: &String)-> io::Result<Vec<u8>>;
    fn list_dir(&self,dir: &String)->Vec<String>;
}