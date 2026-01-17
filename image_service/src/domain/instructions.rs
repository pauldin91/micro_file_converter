use crate::domain::InstructionParseError;
use std::{collections::HashMap, str::FromStr};
use tracing::error;

pub struct Instructions;
impl Instructions {
    pub fn parse_properties<T>(props: &HashMap<String, String>, arg_name: &'static str) -> Option<T>
    where
        T: FromStr,
    {
        let val = props
            .get(arg_name)
            .ok_or_else(|| InstructionParseError::Missing::<String>(arg_name.to_string()));

        match val {
            Ok(res) => match res.parse() {
                Ok(parsed) => Some(parsed),
                Err(_) => {
                    error!("could not parse instruction {}", arg_name);
                    None
                }
            },
            Err(_) => {
                error!("instruction missing {}", arg_name);
                None
            }
        }
    }
}
