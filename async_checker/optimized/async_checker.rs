use std::sync::mpsc;
use std::thread;

struct TaskResult {
    latency: usize,
    status: usize,
}

#[inline(always)]
fn run_task(id: usize) -> TaskResult {
    let seed = ((id as u64).wrapping_mul(1664525) + 1013904223) & 0xFFFFFFFF;
    let latency = (10 + (seed % 990)) as usize;
    let status = if (seed % 7) != 0 {
        200
    } else if (seed % 3) == 0 {
        429
    } else {
        500
    };
    TaskResult { latency, status }
}

fn main() {
    let tasks = 10000;
    let workers = 16;
    let (tx, rx) = mpsc::sync_channel::<TaskResult>(1000);

    let chunk_size = tasks / workers;
    let mut handles = Vec::new();

    for w in 0..workers {
        let tx = tx.clone();
        let start = w * chunk_size;
        let end = if w == workers - 1 { tasks } else { start + chunk_size };
        handles.push(thread::spawn(move || {
            for i in start..end {
                let _ = tx.send(run_task(i));
            }
        }));
    }
    drop(tx);

    let mut ok_count = 0;
    let mut rl_count = 0;
    let mut err_count = 0;
    let mut total_lat = 0u64;
    let mut histogram = [0usize; 1000];

    for res in rx {
        histogram[res.latency] += 1;
        total_lat += res.latency as u64;
        match res.status {
            200 => ok_count += 1,
            429 => rl_count += 1,
            500 => err_count += 1,
            _ => {}
        }
    }

    for h in handles {
        let _ = h.join();
    }

    let mut count = 0;
    let mut p50 = 0;
    let mut p95 = 0;
    let mut p99 = 0;
    let target_p50 = (tasks as f64 * 0.50) as usize;
    let target_p95 = (tasks as f64 * 0.95) as usize;
    let target_p99 = (tasks as f64 * 0.99) as usize;

    for (lat, &c) in histogram.iter().enumerate() {
        if c > 0 {
            if count < target_p50 && count + c >= target_p50 {
                p50 = lat;
            }
            if count < target_p95 && count + c >= target_p95 {
                p95 = lat;
            }
            if count < target_p99 && count + c >= target_p99 {
                p99 = lat;
            }
            count += c;
        }
    }

    println!(
        "Async complete: tasks={}, ok={}, rate_limited={}, errors={}, latency_sum={}, p50={}, p95={}, p99={}",
        tasks, ok_count, rl_count, err_count, total_lat, p50, p95, p99
    );
}
