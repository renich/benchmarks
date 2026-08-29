#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <pthread.h>

#define NUM_TASKS 10000
#define QUEUE_CAP 1000
#define NUM_WORKERS 16

typedef struct {
    int latency;
    int status;
} TaskResult;

static inline TaskResult run_task(int id) {
    uint32_t seed = ((uint64_t)id * 1664525ULL + 1013904223ULL) & 0xFFFFFFFF;
    int latency = 10 + (seed % 990);
    int status = 200;
    if ((seed % 7) == 0) {
        status = ((seed % 3) == 0) ? 429 : 500;
    }
    TaskResult res = { .latency = latency, .status = status };
    return res;
}

typedef struct {
    TaskResult buffer[QUEUE_CAP];
    int head, tail, count, closed;
    pthread_mutex_t lock;
    pthread_cond_t not_full, not_empty;
} ResultQueue;

static ResultQueue res_q;
static pthread_t workers[NUM_WORKERS];

static void q_init(ResultQueue *q) {
    q->head = q->tail = q->count = q->closed = 0;
    pthread_mutex_init(&q->lock, NULL);
    pthread_cond_init(&q->not_full, NULL);
    pthread_cond_init(&q->not_empty, NULL);
}

static int q_push(ResultQueue *q, TaskResult item) {
    pthread_mutex_lock(&q->lock);
    while (q->count == QUEUE_CAP && !q->closed) pthread_cond_wait(&q->not_full, &q->lock);
    if (q->closed) { pthread_mutex_unlock(&q->lock); return 0; }
    q->buffer[q->tail] = item;
    q->tail = (q->tail + 1) % QUEUE_CAP;
    q->count++;
    pthread_cond_signal(&q->not_empty);
    pthread_mutex_unlock(&q->lock);
    return 1;
}

static int q_pop(ResultQueue *q, TaskResult *item) {
    pthread_mutex_lock(&q->lock);
    while (q->count == 0 && !q->closed) pthread_cond_wait(&q->not_empty, &q->lock);
    if (q->count == 0 && q->closed) { pthread_mutex_unlock(&q->lock); return 0; }
    *item = q->buffer[q->head];
    q->head = (q->head + 1) % QUEUE_CAP;
    q->count--;
    pthread_cond_signal(&q->not_full);
    pthread_mutex_unlock(&q->lock);
    return 1;
}

static void q_close(ResultQueue *q) {
    pthread_mutex_lock(&q->lock);
    q->closed = 1;
    pthread_cond_broadcast(&q->not_empty);
    pthread_cond_broadcast(&q->not_full);
    pthread_mutex_unlock(&q->lock);
}

typedef struct {
    int start;
    int end;
} WorkerArg;

static void *worker_fn(void *arg) {
    WorkerArg *w = (WorkerArg *)arg;
    for (int i = w->start; i < w->end; ++i) {
        q_push(&res_q, run_task(i));
    }
    return NULL;
}

static void *closer_fn(void *arg) {
    (void)arg;
    for (int i = 0; i < NUM_WORKERS; ++i) pthread_join(workers[i], NULL);
    q_close(&res_q);
    return NULL;
}

int main(void) {
    q_init(&res_q);
    WorkerArg args[NUM_WORKERS];
    int chunk_size = NUM_TASKS / NUM_WORKERS;

    for (int w = 0; w < NUM_WORKERS; ++w) {
        args[w].start = w * chunk_size;
        args[w].end = (w == NUM_WORKERS - 1) ? NUM_TASKS : (args[w].start + chunk_size);
        pthread_create(&workers[w], NULL, worker_fn, &args[w]);
    }

    pthread_t closer;
    pthread_create(&closer, NULL, closer_fn, NULL);

    int ok_count = 0, rl_count = 0, err_count = 0;
    uint64_t total_lat = 0;
    int histogram[1000] = {0};

    TaskResult res;
    while (q_pop(&res_q, &res)) {
        histogram[res.latency]++;
        total_lat += res.latency;
        switch (res.status) {
            case 200: ok_count++; break;
            case 429: rl_count++; break;
            case 500: err_count++; break;
        }
    }

    pthread_join(closer, NULL);

    int count = 0;
    int p50 = 0, p95 = 0, p99 = 0;
    int target_p50 = (int)(NUM_TASKS * 0.50);
    int target_p95 = (int)(NUM_TASKS * 0.95);
    int target_p99 = (int)(NUM_TASKS * 0.99);

    for (int lat = 0; lat < 1000; ++lat) {
        int c = histogram[lat];
        if (c > 0) {
            if (count < target_p50 && count + c >= target_p50) p50 = lat;
            if (count < target_p95 && count + c >= target_p95) p95 = lat;
            if (count < target_p99 && count + c >= target_p99) p99 = lat;
            count += c;
        }
    }

    printf("Async complete: tasks=%d, ok=%d, rate_limited=%d, errors=%d, latency_sum=%llu, p50=%d, p95=%d, p99=%d\n",
           NUM_TASKS, ok_count, rl_count, err_count, (unsigned long long)total_lat, p50, p95, p99);
    return 0;
}
