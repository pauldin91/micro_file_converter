use std::path::PathBuf;

pub trait Storage: Send + Sync {
    fn get_full_path(&self,filename: &PathBuf) -> PathBuf;
    fn store_file(&self,filename: &PathBuf,content: &Vec<u8>);
    fn get_transformed_filename(&self,old_filename: &PathBuf,transform_type: &String) -> PathBuf;
    fn load(&self,fullpath: PathBuf)->Vec<u8>;
    fn get_files(&self,dir: String)->Vec<PathBuf>;
}