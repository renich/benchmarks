#include <iostream>
#include <vector>
#include <thread>
#include <mutex>
#include <condition_variable>
#include <queue>
#include <cstdint>
#include <string>

constexpr uint64_t FNV_OFFSET = 0xcbf29ce484222325ULL;
constexpr uint64_t FNV_PRIME  = 0x100000001b3ULL;

uint64_t fnv1a(const std::string& s) {
    uint64_t h = FNV_OFFSET;
    for (char c : s) {
        h = (h ^ static_cast<uint8_t>(c)) * FNV_PRIME;
    }
    return h;
}

struct Task {
    int id;
};

struct TaskResult {
    uint64_t checksum;
};

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
        queue_.push(std::move(item));
        cv_not_empty_.notify_one();
        return true;
    }

    bool pop(T& item) {
        std::unique_lock<std::mutex> lock(mtx_);
        cv_not_empty_.wait(lock, [this] { return !queue_.empty() || closed_; });
        if (queue_.empty() && closed_) return false;
        item = std::move(queue_.front());
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
    BoundedQueue<Task> tasks(1000);
    BoundedQueue<TaskResult> results(1000);
    constexpr int workers = 8;

    std::vector<std::thread> worker_threads;
    worker_threads.reserve(workers);

    for (int w = 0; w < workers; ++w) {
        worker_threads.emplace_back([&tasks, &results] {
            Task task;
            while (tasks.pop(task)) {
                std::string payload = "task:item:" + std::to_string(task.id);
                uint64_t chk = fnv1a(payload);
                results.push(TaskResult{chk});
            }
        });
    }

    std::thread closer([&worker_threads, &results] {
        for (auto& t : worker_threads) {
            if (t.joinable()) t.join();
        }
        results.close();
    });

    std::thread producer([&tasks] {
        for (int i = 0; i < 100000; ++i) {
            tasks.push(Task{i});
        }
        tasks.close();
    });

    uint64_t total_checksum = 0;
    int count = 0;
    TaskResult res;
    while (results.pop(res)) {
        total_checksum += res.checksum;
        count++;
    }

    if (producer.joinable()) producer.join();
    if (closer.joinable()) closer.join();

    std::cout << "Pipeline complete: processed=" << count << ", checksum=" << total_checksum << "\n";
    return 0;
}
