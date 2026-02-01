use std::{
    fs::{self, File},
    io::{self, Write},
    path::{Path, PathBuf},
};
use tracing::error;

use crate::{Storage, domain::config};

pub struct LocalStorage {
    upload_dir: PathBuf,
}

impl Default for LocalStorage {
    fn default() -> Self {
        Self::new()
    }
}

impl LocalStorage {
    pub fn new() -> Self {
        let upload_dir = dotenv::var(config::UPLOAD_DIR).unwrap_or(String::from("../uploads"));

        Self {
            upload_dir: PathBuf::from(upload_dir),
        }
    }
    fn get_full_path(&self, dir: &str) -> PathBuf {
        self.upload_dir.join(dir)
    }
}

impl Storage for LocalStorage {
    fn save(&self, filename: &Path, content: &[u8]) {
        let created = File::create(filename);
        match created {
            Ok(mut file) => {
                let _ = file.write(content);
            }
            Err(e) => error!("could not create file : {}", e),
        }
    }

    fn list_dir(&self, dir: &str) -> Vec<String> {
        let location_dir = fs::read_dir(self.get_full_path(dir));
        match location_dir {
            Ok(actual_dir) => {
                let mut filenames = Vec::new();
                for f in actual_dir {
                    match f {
                        Ok(entry) => filenames.push(entry.path().to_string_lossy().into_owned()),
                        Err(e) => {
                            error!("error {}", e);
                            continue;
                        }
                    }
                }
                filenames
            }
            Err(e) => {
                error!("Error: {} not a directory", e);
                Vec::new()
            }
        }
    }

    fn load(&self, fullpath: &str) -> io::Result<Vec<u8>> {
        fs::read(fullpath)
    }

    fn get_transformed_filename(&self, old_filename: &str, transform_type: &str) -> PathBuf {
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
