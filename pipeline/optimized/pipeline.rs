use std::sync::mpsc;
use std::sync::{Arc, Mutex};
use std::thread;

const FNV_OFFSET: u64 = 0xcbf29ce484222325;
const FNV_PRIME: u64 = 0x100000001b3;

#[inline(always)]
fn fnv1a(bytes: &[u8]) -> u64 {
    let mut h = FNV_OFFSET;
    for &b in bytes {
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

        handles.push(thread::spawn(move || {
            let mut buf = [0u8; 32];
            let prefix = b"task:item:";
            loop {
                let task = {
                    let rx = task_rx.lock().unwrap();
                    rx.recv()
                };
                match task {
                    Ok(t) => {
                        buf[..prefix.len()].copy_from_slice(prefix);
                        let mut temp = t.id;
                        let mut idx = 32;
                        if temp == 0 {
                            idx -= 1;
                            buf[idx] = b'0';
                        } else {
                            while temp > 0 {
                                idx -= 1;
                                buf[idx] = b'0' + (temp % 10) as u8;
                                temp /= 10;
                            }
                        }
                        let num_len = 32 - idx;
                        let full_len = prefix.len() + num_len;
                        let mut payload = [0u8; 32];
                        payload[..prefix.len()].copy_from_slice(prefix);
                        payload[prefix.len()..full_len].copy_from_slice(&buf[idx..]);

                        let chk = fnv1a(&payload[..full_len]);
                        let _ = res_tx.send(TaskResult { checksum: chk });
                    }
                    Err(_) => break,
                }
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
