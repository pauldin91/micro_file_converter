use std::{fs::{self, File}, io::Write, path::PathBuf};

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
    fn get_full_path(&self,dir:String)-> PathBuf{
        self.upload_dir.join(dir)
    }
}

impl Storage for LocalStorage{
    fn get_full_path(&self,filename: &PathBuf) -> PathBuf {
        self.upload_dir.clone().join(filename)
    }
    
    fn store_file(&self,filename: &PathBuf,content:&Vec<u8> ) {
        let created = File::create(filename);
        match created {
            Ok(mut file) =>{
                let _ = file.write(&content);
            },
            Err(_) =>(),
        }
    
    }

    fn get_files(&self,dir: &String)-> Vec<PathBuf>{
        let mut filenames= Vec::new();
        for f in fs::read_dir(self.get_full_path(dir.clone())).unwrap(){
            match f {
                Ok(entry)=>filenames.push(entry.path()),
                Err(e)=>{eprint!("error {}",e); continue},
            }
        }

        filenames
    }
    
    fn load(&self,fullpath: &PathBuf) -> Vec<u8>{
        Vec::from(image::open(fullpath.as_path()).unwrap().as_bytes())
    }
    
    fn get_transformed_filename(&self,old_filename: &PathBuf,transform_type: &String) -> PathBuf {
        PathBuf::from(old_filename.as_path().parent().unwrap())
                                    .join(transform_type)
                                    .join(old_filename.as_path().file_name().unwrap())
    }
}
