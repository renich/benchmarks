#!/usr/bin/env ruby

def find_files(dir)
  Dir.glob(File.join(dir, "**", "*.txt"))
end

data_dir = "tree_walk/_data"
unless Dir.exist?(data_dir)
  data_dir = if Dir.exist?("../../_data")
               "../../_data"
             elsif Dir.exist?("../_data")
               "../_data"
             elsif Dir.exist?("_data")
               "_data"
             else
               "tree_walk/_data"
             end
end

files = find_files(data_dir)
file_q = SizedQueue.new(500)
res_q = SizedQueue.new(500)
workers = 8

needle = "category=".freeze

threads = Array.new(workers) do
  Thread.new do
    local_matches = 0
    while (batch = file_q.pop)
      break if batch == :done
      batch.each do |path|
        content = File.binread(path)
        pos = 0
        while (pos = content.index(needle, pos))
          local_matches += 1
          pos += 9
        end
      end
    end
    res_q.push(local_matches)
  end
end

prod_t = Thread.new do
  files.each_slice(50) { |slice| file_q.push(slice) }
  workers.times { file_q.push(:done) }
end

total_matches = 0
workers.times do
  total_matches += res_q.pop
end

prod_t.join
threads.each(&:join)

puts "Tree walk complete: files=#{files.size}, matches=#{total_matches}"
