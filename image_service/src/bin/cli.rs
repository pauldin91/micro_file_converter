use std::{env, fs, path::PathBuf};

use image_service::{Fractal, application::LocalStorage, domain::{Storage}};


fn main(){
     let args: Vec<String> = env::args().collect();
    dbg!(&args);

    let width: u32 = args[1].clone().parse().unwrap();
    let height: u32 = args[2].clone().parse().unwrap();
    let scale: f32 = args[3].clone().parse().unwrap();
    let dir: String = args[4].clone();
    
    let storage = Box::new(LocalStorage::new());
    let fractal= Fractal::new(width,height,scale);
    let img_res = fractal.apply();

    match img_res {
        Ok(img)=>{
            let base_dir = PathBuf::from("../uploads").join(dir);
            let _ =fs::create_dir(&base_dir);
            let filename = base_dir.clone().join(format!("scale_{}_fractal.png",scale));
            storage.store_file(&filename,&img);

        },
        Err(e)=>eprintln!("{}",e),

    }


}