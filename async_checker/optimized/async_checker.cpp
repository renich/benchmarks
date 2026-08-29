#include <iostream>
#include <vector>
#include <thread>
#include <mutex>
#include <queue>
#include <condition_variable>
#include <array>
#include <cstdint>

constexpr int NUM_TASKS = 10000;
constexpr int NUM_WORKERS = 16;
constexpr size_t QUEUE_CAP = 1000;

struct TaskResult {
    int latency;
    int status;
};

inline TaskResult run_task(int id) {
    uint32_t seed = ((uint64_t)id * 1664525ULL + 1013904223ULL) & 0xFFFFFFFF;
    int latency = 10 + (seed % 990);
    int status = 200;
    if ((seed % 7) == 0) {
        status = ((seed % 3) == 0) ? 429 : 500;
    }
    return {latency, status};
}

template<typename T>
class BoundedQueue {
private:
    std::queue<T> queue_;
    size_t capacity_;
    std::mutex mtx_;
    std::condition_variable cv_not_full_;
    std::condition_variable cv_not_empty_;
    bool closed_ = false;

public:
    explicit BoundedQueue(size_t capacity) : capacity_(capacity) {}

    bool push(T item) {
        std::unique_lock<std::mutex> lock(mtx_);
        cv_not_full_.wait(lock, [this] { return queue_.size() < capacity_ || closed_; });
        if (closed_) return false;
        queue_.push(item);
        cv_not_empty_.notify_one();
        return true;
    }

    bool pop(T& item) {
        std::unique_lock<std::mutex> lock(mtx_);
        cv_not_empty_.wait(lock, [this] { return !queue_.empty() || closed_; });
        if (queue_.empty() && closed_) return false;
        item = queue_.front();
        queue_.pop();
        cv_not_full_.notify_one();
        return true;
    }

    void close() {
        std::unique_lock<std::mutex> lock(mtx_);
        closed_ = true;
        cv_not_empty_.notify_all();
        cv_not_full_.notify_all();
    }
};

int main() {
    BoundedQueue<TaskResult> res_q(QUEUE_CAP);
    std::vector<std::thread> workers;
    int chunk_size = NUM_TASKS / NUM_WORKERS;

    for (int w = 0; w < NUM_WORKERS; ++w) {
        int start = w * chunk_size;
        int end = (w == NUM_WORKERS - 1) ? NUM_TASKS : (start + chunk_size);
        workers.emplace_back([&res_q, start, end] {
            for (int i = start; i < end; ++i) {
                res_q.push(run_task(i));
            }
        });
    }

    std::thread closer([&workers, &res_q] {
        for (auto& t : workers) {
            if (t.joinable()) t.join();
        }
        res_q.close();
    });

    int ok_count = 0, rl_count = 0, err_count = 0;
    uint64_t total_lat = 0;
    std::array<int, 1000> histogram{};

    TaskResult res;
    while (res_q.pop(res)) {
        histogram[res.latency]++;
        total_lat += res.latency;
        switch (res.status) {
            case 200: ok_count++; break;
            case 429: rl_count++; break;
            case 500: err_count++; break;
        }
    }

    if (closer.joinable()) closer.join();

    int count = 0;
    int p50 = 0, p95 = 0, p99 = 0;
    int target_p50 = static_cast<int>(NUM_TASKS * 0.50);
    int target_p95 = static_cast<int>(NUM_TASKS * 0.95);
    int target_p99 = static_cast<int>(NUM_TASKS * 0.99);

    for (int lat = 0; lat < 1000; ++lat) {
        int c = histogram[lat];
        if (c > 0) {
            if (count < target_p50 && count + c >= target_p50) p50 = lat;
            if (count < target_p95 && count + c >= target_p95) p95 = lat;
            if (count < target_p99 && count + c >= target_p99) p99 = lat;
            count += c;
        }
    }

    std::cout << "Async complete: tasks=" << NUM_TASKS
              << ", ok=" << ok_count
              << ", rate_limited=" << rl_count
              << ", errors=" << err_count
              << ", latency_sum=" << total_lat
              << ", p50=" << p50
              << ", p95=" << p95
              << ", p99=" << p99 << "\n";
    return 0;
}
