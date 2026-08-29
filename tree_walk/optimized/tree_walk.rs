use std::fs;
use std::path::{Path, PathBuf};
use std::sync::mpsc;
use std::sync::{Arc, Mutex};
use std::thread;

fn find_files(dir: &Path, list: &mut Vec<PathBuf>) {
    if let Ok(entries) = fs::read_dir(dir) {
        for entry in entries.flatten() {
            let path = entry.path();
            if path.is_dir() {
                find_files(&path, list);
            } else if path.extension().map_or(false, |ext| ext == "txt") {
                list.push(path);
            }
        }
    }
}

fn count_needle(haystack: &[u8], needle: &[u8]) -> usize {
    let mut count = 0;
    let mut i = 0;
    if haystack.len() < needle.len() {
        return 0;
    }
    let limit = haystack.len() - needle.len();
    while i <= limit {
        if &haystack[i..i + needle.len()] == needle {
            count += 1;
            i += needle.len();
        } else {
            i += 1;
        }
    }
    count
}

fn main() {
    let mut data_dir = PathBuf::from("tree_walk/_data");
    if !data_dir.exists() {
        data_dir = if Path::new("../../_data").exists() {
            PathBuf::from("../../_data")
        } else if Path::new("../_data").exists() {
            PathBuf::from("../_data")
        } else {
            PathBuf::from("_data")
        };
    }

    let mut files = Vec::new();
    find_files(&data_dir, &mut files);
    let total_files = files.len();

    let (tx, rx) = mpsc::sync_channel::<PathBuf>(500);
    let (res_tx, res_rx) = mpsc::sync_channel::<usize>(500);
    let rx = Arc::new(Mutex::new(rx));
    let workers = 8;

    let mut handles = Vec::new();
    for _ in 0..workers {
        let rx = Arc::clone(&rx);
        let res_tx = res_tx.clone();
        handles.push(thread::spawn(move || {
            let mut matches = 0;
            let needle = b"category=";
            loop {
                let file = {
                    let lock = rx.lock().unwrap();
                    lock.recv()
                };
                match file {
                    Ok(path) => {
                        if let Ok(bytes) = fs::read(path) {
                            matches += count_needle(&bytes, needle);
                        }
                    }
                    Err(_) => break,
                }
            }
            let _ = res_tx.send(matches);
        }));
    }
    drop(res_tx);

    thread::spawn(move || {
        for f in files {
            let _ = tx.send(f);
        }
    });

    let mut total_matches = 0;
    for count in res_rx {
        total_matches += count;
    }

    for h in handles {
        let _ = h.join();
    }

    println!("Tree walk complete: files={}, matches={}", total_files, total_matches);
}
