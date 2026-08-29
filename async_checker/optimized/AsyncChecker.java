import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;

public class AsyncChecker {
    static class TaskResult {
        final int latency;
        final int status;
        TaskResult(int latency, int status) {
            this.latency = latency;
            this.status = status;
        }
    }

    private static TaskResult runTask(int id) {
        long seed = (((long)id * 1664525L + 1013904223L) & 0xFFFFFFFFL);
        int latency = (int)(10 + (seed % 990));
        int status = 200;
        if ((seed % 7) == 0) {
            status = ((seed % 3) == 0) ? 429 : 500;
        }
        return new TaskResult(latency, status);
    }

    private static final TaskResult POISON = new TaskResult(-1, -1);

    public static void main(String[] args) throws Exception {
        int tasks = 10000;
        int workers = 16;
        BlockingQueue<TaskResult> resQueue = new ArrayBlockingQueue<>(1000);
        Thread[] threads = new Thread[workers];

        int chunkSize = tasks / workers;
        for (int w = 0; w < workers; w++) {
            final int start = w * chunkSize;
            final int end = (w == workers - 1) ? tasks : (start + chunkSize);
            threads[w] = new Thread(() -> {
                try {
                    for (int i = start; i < end; i++) {
                        resQueue.put(runTask(i));
                    }
                } catch (InterruptedException ignored) {}
            });
            threads[w].start();
        }

        Thread closer = new Thread(() -> {
            try {
                for (Thread t : threads) t.join();
                resQueue.put(POISON);
            } catch (InterruptedException ignored) {}
        });
        closer.start();

        int okCount = 0, rlCount = 0, errCount = 0;
        long totalLat = 0;
        int[] histogram = new int[1000];

        while (true) {
            TaskResult res = resQueue.take();
            if (res.latency == -1) break;
            histogram[res.latency]++;
            totalLat += res.latency;
            switch (res.status) {
                case 200 -> okCount++;
                case 429 -> rlCount++;
                case 500 -> errCount++;
            }
        }

        closer.join();

        int count = 0;
        int p50 = 0, p95 = 0, p99 = 0;
        int targetP50 = (int)(tasks * 0.50);
        int targetP95 = (int)(tasks * 0.95);
        int targetP99 = (int)(tasks * 0.99);

        for (int lat = 0; lat < 1000; lat++) {
            int c = histogram[lat];
            if (c > 0) {
                if (count < targetP50 && count + c >= targetP50) p50 = lat;
                if (count < targetP95 && count + c >= targetP95) p95 = lat;
                if (count < targetP99 && count + c >= targetP99) p99 = lat;
                count += c;
            }
        }

        System.out.printf("Async complete: tasks=%d, ok=%d, rate_limited=%d, errors=%d, latency_sum=%d, p50=%d, p95=%d, p99=%d\n",
                tasks, okCount, rlCount, errCount, totalLat, p50, p95, p99);
    }
}
