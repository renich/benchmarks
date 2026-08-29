#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <pthread.h>

#define FNV_OFFSET 0xcbf29ce484222325ULL
#define FNV_PRIME  0x100000001b3ULL
#define QUEUE_CAP  1000
#define NUM_TASKS  100000
#define NUM_WORKERS 8

static inline uint64_t fnv1a(const char *data, size_t len) {
    uint64_t h = FNV_OFFSET;
    for (size_t i = 0; i < len; ++i) {
        h = (h ^ (uint8_t)data[i]) * FNV_PRIME;
    }
    return h;
}

typedef struct {
    int id;
} Task;

typedef struct {
    uint64_t checksum;
} TaskResult;

typedef struct {
    Task buffer[QUEUE_CAP];
    int head;
    int tail;
    int count;
    int closed;
    pthread_mutex_t lock;
    pthread_cond_t not_full;
    pthread_cond_t not_empty;
} TaskQueue;

typedef struct {
    TaskResult buffer[QUEUE_CAP];
    int head;
    int tail;
    int count;
    int closed;
    pthread_mutex_t lock;
    pthread_cond_t not_full;
    pthread_cond_t not_empty;
} ResultQueue;

static void task_q_init(TaskQueue *q) {
    q->head = q->tail = q->count = q->closed = 0;
    pthread_mutex_init(&q->lock, NULL);
    pthread_cond_init(&q->not_full, NULL);
    pthread_cond_init(&q->not_empty, NULL);
}

static void result_q_init(ResultQueue *q) {
    q->head = q->tail = q->count = q->closed = 0;
    pthread_mutex_init(&q->lock, NULL);
    pthread_cond_init(&q->not_full, NULL);
    pthread_cond_init(&q->not_empty, NULL);
}

static int task_q_push(TaskQueue *q, Task item) {
    pthread_mutex_lock(&q->lock);
    while (q->count == QUEUE_CAP && !q->closed) {
        pthread_cond_wait(&q->not_full, &q->lock);
    }
    if (q->closed) {
        pthread_mutex_unlock(&q->lock);
        return 0;
    }
    q->buffer[q->tail] = item;
    q->tail = (q->tail + 1) % QUEUE_CAP;
    q->count++;
    pthread_cond_signal(&q->not_empty);
    pthread_mutex_unlock(&q->lock);
    return 1;
}

static int task_q_pop(TaskQueue *q, Task *item) {
    pthread_mutex_lock(&q->lock);
    while (q->count == 0 && !q->closed) {
        pthread_cond_wait(&q->not_empty, &q->lock);
    }
    if (q->count == 0 && q->closed) {
        pthread_mutex_unlock(&q->lock);
        return 0;
    }
    *item = q->buffer[q->head];
    q->head = (q->head + 1) % QUEUE_CAP;
    q->count--;
    pthread_cond_signal(&q->not_full);
    pthread_mutex_unlock(&q->lock);
    return 1;
}

static void task_q_close(TaskQueue *q) {
    pthread_mutex_lock(&q->lock);
    q->closed = 1;
    pthread_cond_broadcast(&q->not_empty);
    pthread_cond_broadcast(&q->not_full);
    pthread_mutex_unlock(&q->lock);
}

static int result_q_push(ResultQueue *q, TaskResult item) {
    pthread_mutex_lock(&q->lock);
    while (q->count == QUEUE_CAP && !q->closed) {
        pthread_cond_wait(&q->not_full, &q->lock);
    }
    if (q->closed) {
        pthread_mutex_unlock(&q->lock);
        return 0;
    }
    q->buffer[q->tail] = item;
    q->tail = (q->tail + 1) % QUEUE_CAP;
    q->count++;
    pthread_cond_signal(&q->not_empty);
    pthread_mutex_unlock(&q->lock);
    return 1;
}

static int result_q_pop(ResultQueue *q, TaskResult *item) {
    pthread_mutex_lock(&q->lock);
    while (q->count == 0 && !q->closed) {
        pthread_cond_wait(&q->not_empty, &q->lock);
    }
    if (q->count == 0 && q->closed) {
        pthread_mutex_unlock(&q->lock);
        return 0;
    }
    *item = q->buffer[q->head];
    q->head = (q->head + 1) % QUEUE_CAP;
    q->count--;
    pthread_cond_signal(&q->not_full);
    pthread_mutex_unlock(&q->lock);
    return 1;
}

static void result_q_close(ResultQueue *q) {
    pthread_mutex_lock(&q->lock);
    q->closed = 1;
    pthread_cond_broadcast(&q->not_empty);
    pthread_cond_broadcast(&q->not_full);
    pthread_mutex_unlock(&q->lock);
}

static TaskQueue tasks;
static ResultQueue results;
static pthread_t workers[NUM_WORKERS];

static void *worker_fn(void *arg) {
    (void)arg;
    Task t;
    char buf[32];
    const char *prefix = "task:item:";
    const size_t prefix_len = 10;
    memcpy(buf, prefix, prefix_len);

    while (task_q_pop(&tasks, &t)) {
        char num_buf[12];
        int temp = t.id;
        int digits = 0;
        if (temp == 0) {
            num_buf[digits++] = '0';
        } else {
            while (temp > 0) {
                num_buf[digits++] = (char)('0' + (temp % 10));
                temp /= 10;
            }
        }
        size_t pos = prefix_len;
        for (int j = digits - 1; j >= 0; --j) {
            buf[pos++] = num_buf[j];
        }
        uint64_t chk = fnv1a(buf, pos);
        TaskResult r = { .checksum = chk };
        result_q_push(&results, r);
    }
    return NULL;
}

static void *closer_fn(void *arg) {
    (void)arg;
    for (int i = 0; i < NUM_WORKERS; ++i) {
        pthread_join(workers[i], NULL);
    }
    result_q_close(&results);
    return NULL;
}

static void *producer_fn(void *arg) {
    (void)arg;
    for (int i = 0; i < NUM_TASKS; ++i) {
        Task t = { .id = i };
        task_q_push(&tasks, t);
    }
    task_q_close(&tasks);
    return NULL;
}

int main(void) {
    task_q_init(&tasks);
    result_q_init(&results);

    for (int i = 0; i < NUM_WORKERS; ++i) {
        pthread_create(&workers[i], NULL, worker_fn, NULL);
    }

    pthread_t producer, closer;
    pthread_create(&producer, NULL, producer_fn, NULL);
    pthread_create(&closer, NULL, closer_fn, NULL);

    uint64_t total_checksum = 0;
    int count = 0;
    TaskResult res;
    while (result_q_pop(&results, &res)) {
        total_checksum += res.checksum;
        count++;
    }

    pthread_join(producer, NULL);
    pthread_join(closer, NULL);

    printf("Pipeline complete: processed=%d, checksum=%llu\n", count, (unsigned long long)total_checksum);
    return 0;
}
