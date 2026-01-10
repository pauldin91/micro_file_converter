use std::{fs::File, io::Write, path::PathBuf};

use uuid::Uuid;

use crate::domain::{Storage, constants};

pub struct LocalStorage{
    upload_dir: PathBuf
}

impl LocalStorage {
    pub fn new() -> Self {
        let upload_dir = dotenv::var(constants::UPLOAD_DIR).unwrap();
        
        Self{
            upload_dir: PathBuf::from(upload_dir),
        }
    }
}

impl Storage for LocalStorage{
    fn get_full_path(&self,filename: PathBuf) -> PathBuf {
        self.upload_dir.clone().join(filename)
    }
    
    fn store_file(&self,filename: PathBuf,content: Vec<u8> ) {
        let created = File::create(filename);
        match created {
            Ok(mut file) =>{
                let _ = file.write(&content);
            },
            Err(_) =>(),
        }
    
    }

    fn get_files(&self,dir: String)-> Vec<PathBuf>{
        let filenames= Vec::new();

        filenames
    }
    
    fn load(&self,fullpath: PathBuf) {
        todo!()
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