use std::path::PathBuf;

pub trait Storage: Send + Sync {
    fn get_full_path(&self,filename: PathBuf) -> PathBuf;
    fn store_file(&self,filename: PathBuf,content: Vec<u8>);
    fn load(&self,fullpath: PathBuf);
    fn get_files(&self,dir: String)->Vec<PathBuf>;
}