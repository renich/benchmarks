#include <iostream>
#include <vector>
#include <string>
#include <filesystem>
#include <thread>
#include <mutex>
#include <queue>
#include <condition_variable>
#include <cstdio>
#include <cstring>

namespace fs = std::filesystem;

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
    std::string data_dir = "tree_walk/_data";
    if (!fs::exists(data_dir)) {
        if (fs::exists("../../_data")) data_dir = "../../_data";
        else if (fs::exists("../_data")) data_dir = "../_data";
        else if (fs::exists("_data")) data_dir = "_data";
    }

    std::vector<std::string> files;
    for (const auto& entry : fs::recursive_directory_iterator(data_dir)) {
        if (entry.is_regular_file() && entry.path().extension() == ".txt") {
            files.push_back(entry.path().string());
        }
    }

    BoundedQueue<std::string> file_queue(500);
    BoundedQueue<int> res_queue(500);
    constexpr int workers = 8;

    std::vector<std::thread> worker_threads;
    for (int w = 0; w < workers; ++w) {
        worker_threads.emplace_back([&file_queue, &res_queue] {
            std::string path;
            const char* needle = "category=";
            const size_t needle_len = 9;
            char buf[16384];
            int local_matches = 0;

            while (file_queue.pop(path)) {
                FILE* fp = fopen(path.c_str(), "rb");
                if (fp) {
                    size_t bytes = fread(buf, 1, sizeof(buf), fp);
                    fclose(fp);
                    const char* cur = buf;
                    const char* end = buf + bytes;
                    while (cur <= end - needle_len) {
                        const char* found = static_cast<const char*>(memmem(cur, end - cur, needle, needle_len));
                        if (found) {
                            local_matches++;
                            cur = found + needle_len;
                        } else {
                            break;
                        }
                    }
                }
            }
            res_queue.push(local_matches);
        });
    }

    std::thread closer([&worker_threads, &res_queue] {
        for (auto& t : worker_threads) {
            if (t.joinable()) t.join();
        }
        res_queue.close();
    });

    std::thread producer([&files, &file_queue] {
        for (const auto& f : files) {
            file_queue.push(f);
        }
        file_queue.close();
    });

    int total_matches = 0;
    int count = 0;
    while (res_queue.pop(count)) {
        total_matches += count;
    }

    if (producer.joinable()) producer.join();
    if (closer.joinable()) closer.join();

    std::cout << "Tree walk complete: files=" << files.size() << ", matches=" << total_matches << "\n";
    return 0;
}
