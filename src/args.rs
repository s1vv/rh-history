use crate::command::run_command;
use crate::constants::*;
use crate::history::{interactive_select, print_history};

pub fn handle_args() {
    let args: Vec<String> = std::env::args().skip(1).collect();
    match args.as_slice() {
        [] => {
            interactive_select();
        }
        [flag] if flag == FLAG_HISTORY => {
            print_history();
        }
        [flag, index_str] if flag == FLAG_RUN => {
            let index: usize = index_str.parse().expect("❗Invalid command number");
            run_command(index - 1);
        }
        [flag] if flag == FLAG_INTERACTIVE => {
            interactive_select();
        }
        _ => {
            eprintln!("✨Using: rh [-h | -r N | -i]");
        }
    }
}
