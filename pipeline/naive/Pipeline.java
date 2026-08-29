import java.nio.charset.StandardCharsets;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;

public class Pipeline {
    private static final long FNV_OFFSET = 0xcbf29ce484222325L;
    private static final long FNV_PRIME  = 0x100000001b3L;

    public static long fnv1a(byte[] data, int len) {
        long h = FNV_OFFSET;
        for (int i = 0; i < len; i++) {
            h = (h ^ (data[i] & 0xFF)) * FNV_PRIME;
        }
        return h;
    }

    static class Task {
        final int id;
        Task(int id) { this.id = id; }
    }

    static class TaskResult {
        final int id;
        final long checksum;
        TaskResult(int id, long checksum) { this.id = id; this.checksum = checksum; }
    }

    private static final Task POISON_TASK = new Task(-1);
    private static final TaskResult POISON_RESULT = new TaskResult(-1, 0);

    public static void main(String[] args) throws Exception {
        BlockingQueue<Task> taskQueue = new ArrayBlockingQueue<>(1000);
        BlockingQueue<TaskResult> resultQueue = new ArrayBlockingQueue<>(1000);
        int workers = 8;

        Thread[] workerThreads = new Thread[workers];

        for (int w = 0; w < workers; w++) {
            workerThreads[w] = new Thread(() -> {
                try {
                    while (true) {
                        Task task = taskQueue.take();
                        if (task.id == -1) break;

                        String payload = "task:item:" + task.id;
                        byte[] bytes = payload.getBytes(StandardCharsets.US_ASCII);
                        long chk = fnv1a(bytes, bytes.length);
                        resultQueue.put(new TaskResult(task.id, chk));
                    }
                } catch (InterruptedException ignored) {}
            });
            workerThreads[w].start();
        }

        Thread closer = new Thread(() -> {
            try {
                for (Thread t : workerThreads) t.join();
                resultQueue.put(POISON_RESULT);
            } catch (InterruptedException ignored) {}
        });
        closer.start();

        Thread producer = new Thread(() -> {
            try {
                for (int i = 0; i < 100000; i++) {
                    taskQueue.put(new Task(i));
                }
                for (int w = 0; w < workers; w++) {
                    taskQueue.put(POISON_TASK);
                }
            } catch (InterruptedException ignored) {}
        });
        producer.start();

        long total = 0;
        int count = 0;
        while (true) {
            TaskResult res = resultQueue.take();
            if (res.id == -1) break;
            total += res.checksum;
            count++;
        }

        producer.join();
        closer.join();

        System.out.println("Pipeline complete: processed=" + count + ", checksum=" + Long.toUnsignedString(total));
    }
}
