#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <sys/stat.h>
#include <pthread.h>

#define MAX_FILES 5000
#define QUEUE_CAP 500
#define NUM_WORKERS 8

static char *file_list[MAX_FILES];
static int file_count = 0;

static void find_files(const char *dir) {
    DIR *dp = opendir(dir);
    if (!dp) return;
    struct dirent *ep;
    char path[1024];

    while ((ep = readdir(dp)) != NULL) {
        if (strcmp(ep->d_name, ".") == 0 || strcmp(ep->d_name, "..") == 0) continue;
        snprintf(path, sizeof(path), "%s/%s", dir, ep->d_name);
        struct stat st;
        if (stat(path, &st) == 0) {
            if (S_ISDIR(st.st_mode)) {
                find_files(path);
            } else if (S_ISREG(st.st_mode) && strstr(ep->d_name, ".txt")) {
                if (file_count < MAX_FILES) {
                    file_list[file_count++] = strdup(path);
                }
            }
        }
    }
    closedir(dp);
}

typedef struct {
    char *buffer[QUEUE_CAP];
    int head, tail, count, closed;
    pthread_mutex_t lock;
    pthread_cond_t not_full, not_empty;
} FileQueue;

typedef struct {
    int buffer[QUEUE_CAP];
    int head, tail, count, closed;
    pthread_mutex_t lock;
    pthread_cond_t not_full, not_empty;
} IntQueue;

static FileQueue file_q;
static IntQueue res_q;
static pthread_t workers[NUM_WORKERS];

static void q_init(FileQueue *q) {
    q->head = q->tail = q->count = q->closed = 0;
    pthread_mutex_init(&q->lock, NULL);
    pthread_cond_init(&q->not_full, NULL);
    pthread_cond_init(&q->not_empty, NULL);
}

static void iq_init(IntQueue *q) {
    q->head = q->tail = q->count = q->closed = 0;
    pthread_mutex_init(&q->lock, NULL);
    pthread_cond_init(&q->not_full, NULL);
    pthread_cond_init(&q->not_empty, NULL);
}

static int q_push(FileQueue *q, char *item) {
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

static int q_pop(FileQueue *q, char **item) {
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

static void q_close(FileQueue *q) {
    pthread_mutex_lock(&q->lock);
    q->closed = 1;
    pthread_cond_broadcast(&q->not_empty);
    pthread_cond_broadcast(&q->not_full);
    pthread_mutex_unlock(&q->lock);
}

static int iq_push(IntQueue *q, int item) {
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

static int iq_pop(IntQueue *q, int *item) {
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

static void iq_close(IntQueue *q) {
    pthread_mutex_lock(&q->lock);
    q->closed = 1;
    pthread_cond_broadcast(&q->not_empty);
    pthread_cond_broadcast(&q->not_full);
    pthread_mutex_unlock(&q->lock);
}

static void *worker_fn(void *arg) {
    (void)arg;
    char *path;
    char buf[16384];
    const char *needle = "category=";
    const size_t needle_len = 9;
    int local_matches = 0;

    while (q_pop(&file_q, &path)) {
        FILE *fp = fopen(path, "rb");
        if (fp) {
            size_t bytes = fread(buf, 1, sizeof(buf), fp);
            fclose(fp);
            const char *cur = buf;
            const char *end = buf + bytes;
            while (cur <= end - needle_len) {
                const char *found = (const char *)memmem(cur, end - cur, needle, needle_len);
                if (found) {
                    local_matches++;
                    cur = found + needle_len;
                } else {
                    break;
                }
            }
        }
    }
    iq_push(&res_q, local_matches);
    return NULL;
}

static void *closer_fn(void *arg) {
    (void)arg;
    for (int i = 0; i < NUM_WORKERS; ++i) pthread_join(workers[i], NULL);
    iq_close(&res_q);
    return NULL;
}

static void *producer_fn(void *arg) {
    (void)arg;
    for (int i = 0; i < file_count; ++i) {
        q_push(&file_q, file_list[i]);
    }
    q_close(&file_q);
    return NULL;
}

int main(void) {
    const char *dir = "tree_walk/_data";
    struct stat st;
    if (stat(dir, &st) != 0) {
        dir = (stat("_data", &st) == 0) ? "_data" : "../_data";
    }

    find_files(dir);

    q_init(&file_q);
    iq_init(&res_q);

    for (int i = 0; i < NUM_WORKERS; ++i) pthread_create(&workers[i], NULL, worker_fn, NULL);

    pthread_t producer, closer;
    pthread_create(&producer, NULL, producer_fn, NULL);
    pthread_create(&closer, NULL, closer_fn, NULL);

    int total_matches = 0;
    int count = 0;
    while (iq_pop(&res_q, &count)) {
        total_matches += count;
    }

    pthread_join(producer, NULL);
    pthread_join(closer, NULL);

    printf("Tree walk complete: files=%d, matches=%d\n", file_count, total_matches);
    return 0;
}
