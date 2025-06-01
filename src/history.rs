use crate::command::run_raw_command;
use crate::constants::MAX_HISTORY_LENGTH;
use skim::prelude::*;
use std::{
    collections::HashSet,
    fs::{File, OpenOptions},
    io::{BufRead, BufReader, Write},
    path::PathBuf,
    process::Command,
};

pub fn print_history() {
    let entries = read_history_unique();

    for (i, e) in entries.into_iter().take(9).enumerate() {
        println!("{:>4}: {}", i + 1, e);
    }
}

fn history_path() -> PathBuf {
    dirs::home_dir()
        .unwrap_or_else(|| PathBuf::from("/tmp"))
        .join(".rh_history")
}

pub fn read_history_unique() -> Vec<String> {
    let path = history_path();
    let file = match File::open(&path) {
        Ok(f) => f,
        Err(_) => return Vec::new(),
    };
    let reader = BufReader::new(file);

    let lines: Vec<String> = reader.lines().flatten().collect();
    let mut seen = HashSet::new();
    let mut unique = Vec::new();

    // читаем и собираем уникальные строки, сохраняя только последние N
    for line in lines.into_iter().rev() {
        if seen.insert(line.clone()) {
            unique.push(line);
            if unique.len() >= MAX_HISTORY_LENGTH {
                break;
            }
        }
    }

    unique.reverse(); // чтобы вернуть в хронологическом порядке

    // обновляем файл, если удалось прочитать хоть что-то
    if !unique.is_empty() {
        if let Ok(mut file) = OpenOptions::new().write(true).truncate(true).open(&path) {
            for line in &unique {
                writeln!(file, "{}", line).ok();
            }
        }
    }

    unique
}

pub fn interactive_select() {
    let entries = read_history_unique();

    let (tx, rx): (SkimItemSender, SkimItemReceiver) = unbounded();

    for entry in entries.iter().rev() {
        let display = format!("{entry}");
        let _ = tx.send(Arc::new(display));
    }
    drop(tx);

    let options = SkimOptionsBuilder::default()
        .height("40%".to_string())
        .multi(false)
        .prompt("Выберите команду > ".to_string())
        .build()
        .unwrap();

    let output = Skim::run_with(&options, Some(rx));

    let _ = Command::new("clear").status();

    if let Some(out) = output {
        if out.is_abort {
            // Пользователь нажал Ctrl+C или Esc — выходим без выполнения
            println!("❌ Отмена выбора команды");
            return;
        }

        if let Some(selected) = out.selected_items.first() {
            if let Some((cwd, cmd)) = selected.output().split_once('\t') {
                if let Err(e) = std::env::set_current_dir(cwd.trim()) {
                    eprintln!("❗Не удалось перейти в директорию {}: {}", cwd, e);
                    return;
                }

                println!("🚀 Пуск: {}", cmd);
                run_raw_command(cmd.trim());
            }
        }
    }
}
