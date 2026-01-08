use std::collections::HashMap;

use serde::Deserialize;

#[derive(Debug, Deserialize)]
pub struct TransformDto{
    pub name: String,
    pub props: HashMap<String,String>
}
