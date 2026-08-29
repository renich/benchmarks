import java.io.File;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;

public class TreeWalk {
    private static void findFiles(File dir, List<File> list) {
        File[] files = dir.listFiles();
        if (files != null) {
            for (File f : files) {
                if (f.isDirectory()) {
                    findFiles(f, list);
                } else if (f.getName().endsWith(".txt")) {
                    list.add(f);
                }
            }
        }
    }

    public static void main(String[] args) throws Exception {
        File dataDir = new File("tree_walk/_data");
        if (!dataDir.exists()) {
            if (new File("../../_data").exists()) dataDir = new File("../../_data");
            else if (new File("../_data").exists()) dataDir = new File("../_data");
            else dataDir = new File("_data");
        }

        List<File> files = new ArrayList<>();
        findFiles(dataDir, files);

        BlockingQueue<File> fileQueue = new ArrayBlockingQueue<>(500);
        BlockingQueue<Integer> resQueue = new ArrayBlockingQueue<>(500);
        int workers = 8;
        Thread[] workerThreads = new Thread[workers];
        File poison = new File("");

        byte[] needle = "category=".getBytes();

        for (int w = 0; w < workers; w++) {
            workerThreads[w] = new Thread(() -> {
                try {
                    int localMatches = 0;
                    while (true) {
                        File f = fileQueue.take();
                        if (f.getPath().isEmpty()) break;
                        byte[] bytes = Files.readAllBytes(f.toPath());
                        int limit = bytes.length - needle.length;
                        for (int i = 0; i <= limit; i++) {
                            boolean match = true;
                            for (int j = 0; j < needle.length; j++) {
                                if (bytes[i + j] != needle[j]) {
                                    match = false;
                                    break;
                                }
                            }
                            if (match) {
                                localMatches++;
                                i += needle.length - 1;
                            }
                        }
                    }
                    resQueue.put(localMatches);
                } catch (Exception ignored) {}
            });
            workerThreads[w].start();
        }

        Thread producer = new Thread(() -> {
            try {
                for (File f : files) {
                    fileQueue.put(f);
                }
                for (int w = 0; w < workers; w++) {
                    fileQueue.put(poison);
                }
            } catch (Exception ignored) {}
        });
        producer.start();

        int totalMatches = 0;
        for (int w = 0; w < workers; w++) {
            totalMatches += resQueue.take();
        }

        producer.join();
        for (Thread t : workerThreads) t.join();

        System.out.println("Tree walk complete: files=" + files.size() + ", matches=" + totalMatches);
    }
}
