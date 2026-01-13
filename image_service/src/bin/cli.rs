use std::{fs, path::PathBuf};

use image_service::{Fractal, application::LocalStorage, domain::{Storage}};
use uuid::Uuid;


fn main(){
    let storage = Box::new(LocalStorage::new());
    let fractal= Fractal::new();
    let img_res = fractal.apply();

    match img_res {
        Ok(img)=>{
            let base_dir = PathBuf::from("../uploads").join(Uuid::new_v4().to_string());
            let _ =fs::create_dir(&base_dir);
            let filename = base_dir.clone().join("fractal.png");
            storage.store_file(&filename,&img);

        },
        Err(e)=>eprintln!("{}",e),

    }


}