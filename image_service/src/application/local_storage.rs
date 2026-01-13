use std::{
    fs::{self, File}, io::{self, Write}, path::PathBuf
};

use crate::domain::{Storage, constants};

pub struct LocalStorage {
    upload_dir: PathBuf,
}

impl LocalStorage {
    pub fn new() -> Self {
        let upload_dir = dotenv::var(constants::UPLOAD_DIR).unwrap();

        Self {
            upload_dir: PathBuf::from(upload_dir),
        }
    }
    fn get_full_path(&self, dir: String) -> PathBuf {
        self.upload_dir.join(dir)
    }
}

impl Storage for LocalStorage {
    fn get_full_path(&self, filename: &PathBuf) -> PathBuf {
        self.upload_dir.clone().join(filename)
    }

    fn store_file(&self, filename: &PathBuf, content: &Vec<u8>) {
        let created = File::create(filename);
        match created {
            Ok(mut file) => {
                let _ = file.write(&content);
            }
            Err(e) => eprintln!("could not create file : {}",e),
        }
    }

    fn get_files(&self, dir: &String) -> Vec<String> {
        let mut filenames = Vec::new();
        for f in fs::read_dir(self.get_full_path(dir.clone())).unwrap() {
            match f {
                Ok(entry) => filenames.push(entry.path().to_string_lossy().into_owned()),
                Err(e) => {
                    eprint!("error {}", e);
                    continue;
                }
            }
        }

        filenames
    }

    fn load(&self, fullpath: &String) -> io::Result<Vec<u8>> {
        Ok(fs::read(fullpath)?)
    }

    fn get_transformed_filename(&self, old_filename: &String, transform_type: &String) -> PathBuf {
        let old_path = PathBuf::from(old_filename);
        let _ = fs::create_dir(old_path.parent().unwrap().join("transformed").as_path());
        let filename = old_path.file_name().unwrap().to_str().unwrap();
        old_path
            .parent()
            .unwrap()
            .join("transformed")
            .join(format!("{}_{}", transform_type, filename))
    }
}
