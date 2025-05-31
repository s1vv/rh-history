use std::io::BufRead;
use std::process::Command;

pub fn run_command(index: usize) {
    let file = std::fs::File::open(history_path()).expect("❗Couldn't open history");
    let lines: Vec<String> = std::io::BufReader::new(file).lines().flatten().collect();

    if let Some(line) = lines.get(index) {
        if let Some((cwd, cmd)) = line.split_once('\t') {
            if let Err(e) = std::env::set_current_dir(cwd.trim()) {
                eprintln!("❗Couldn't navigate to the directory {}: {}", cwd, e);
                return;
            }
            println!("📍 {} ➜ {}", cwd.trim(), cmd.trim());
            run_raw_command(cmd.trim());
        } else {
            eprintln!("❗Invalid line in the history: {}", line);
        }
    } else {
        eprintln!("❗The command with the number {} was not found", index + 1);
    }
}

pub fn run_raw_command(cmd: &str) {
    let status = Command::new("sh")
        .arg("-c")
        .arg(cmd)
        .status()
        .expect("❗Couldn't run the command");

    std::process::exit(status.code().unwrap_or(1));
}

fn history_path() -> std::path::PathBuf {
    dirs::home_dir()
        .unwrap_or_else(|| "/tmp".into())
        .join(".rh_history")
}
