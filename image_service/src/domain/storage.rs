use std::{io, path::{PathBuf}};

pub trait Storage: Send + Sync {
    fn store_file(&self,filename: &PathBuf,content: &Vec<u8>);
    fn get_transformed_filename(&self,old_filename: &String,transform_type: &String) -> PathBuf;
    fn load(&self,fullpath: &String)-> io::Result<Vec<u8>>;
    fn get_files(&self,dir: &String)->Vec<String>;
}