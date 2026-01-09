use std::path::PathBuf;

pub trait Storage{
    fn get_file(&self,filename: PathBuf);
    fn store_file(&self,filename: PathBuf,content: Vec<u8>);
    fn get_files(&self,dir: String)->Vec<String>;
}