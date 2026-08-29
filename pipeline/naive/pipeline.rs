use std::sync::mpsc;
use std::sync::{Arc, Mutex};
use std::thread;

const FNV_OFFSET: u64 = 0xcbf29ce484222325;
const FNV_PRIME: u64 = 0x100000001b3;

fn fnv1a(s: &str) -> u64 {
    let mut h = FNV_OFFSET;
    for &b in s.as_bytes() {
        h = (h ^ (b as u64)).wrapping_mul(FNV_PRIME);
    }
    h
}

struct Task {
    id: usize,
}

struct TaskResult {
    checksum: u64,
}

fn main() {
    let (task_tx, task_rx) = mpsc::sync_channel::<Task>(1000);
    let (res_tx, res_rx) = mpsc::sync_channel::<TaskResult>(1000);
    let workers = 8;

    let task_rx = Arc::new(Mutex::new(task_rx));

    let mut handles = Vec::with_capacity(workers);
    for _ in 0..workers {
        let task_rx = Arc::clone(&task_rx);
        let res_tx = res_tx.clone();

        handles.push(thread::spawn(move || loop {
            let task = {
                let rx = task_rx.lock().unwrap();
                rx.recv()
            };
            match task {
                Ok(t) => {
                    let payload = format!("task:item:{}", t.id);
                    let chk = fnv1a(&payload);
                    let _ = res_tx.send(TaskResult { checksum: chk });
                }
                Err(_) => break,
            }
        }));
    }
    drop(res_tx);

    thread::spawn(move || {
        for i in 0..100_000 {
            let _ = task_tx.send(Task { id: i });
        }
    });

    let mut total: u64 = 0;
    let mut count = 0;
    for res in res_rx {
        total = total.wrapping_add(res.checksum);
        count += 1;
    }

    for h in handles {
        let _ = h.join();
    }

    println!("Pipeline complete: processed={}, checksum={}", count, total);
}
