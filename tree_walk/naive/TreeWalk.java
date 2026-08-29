import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

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

        Pattern pattern = Pattern.compile("category=([A-Z_]+)");

        for (int w = 0; w < workers; w++) {
            workerThreads[w] = new Thread(() -> {
                try {
                    int localMatches = 0;
                    while (true) {
                        File f = fileQueue.take();
                        if (f.getPath().isEmpty()) break;
                        String content = Files.readString(f.toPath());
                        Matcher m = pattern.matcher(content);
                        while (m.find()) {
                            localMatches++;
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
