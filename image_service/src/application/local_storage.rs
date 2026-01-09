use std::path::PathBuf;

use uuid::Uuid;

use crate::domain::Storage;

pub struct LocalStorage{
    upload_dir: PathBuf
}





impl Storage for LocalStorage{
    fn get_file(&self,filename: PathBuf){

    }
    
    fn store_file(&self,filename: PathBuf,content: Vec<u8> ) {
        todo!()
    }

    fn get_files(&self,dir: String)-> Vec<String>{
        let filenames= Vec::new();

        filenames
    }
}


impl LocalStorage{
    fn get_file_location(filename: PathBuf) -> PathBuf{
        PathBuf::from(Uuid::new_v4().to_string()).join(filename)
    }

    fn get_save_path(method: &str, batch_id: String, filename: &PathBuf) -> PathBuf {
        PathBuf::from(batch_id).join(Self::get_transformed_filename(method, filename))
    }

    fn get_transformed_filename(transform_name: &str, inputfile: &PathBuf) -> PathBuf {
        let filename = format!(
            "{}_{}",
            transform_name,
            inputfile
            .file_name()
            .unwrap()
            .to_string_lossy()
        );
        PathBuf::from(filename)
    }
    
}