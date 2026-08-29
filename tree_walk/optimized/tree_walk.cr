require "wait_group"

def find_files(dir : String, list : Array(String))
  Dir.each_child(dir) do |entry|
    path = File.join(dir, entry)
    if Dir.exists?(path)
      find_files(path, list)
    elsif entry.ends_with?(".txt")
      list << path
    end
  end
end

def main
  data_dir = "tree_walk/_data"
  unless Dir.exists?(data_dir)
    data_dir = if Dir.exists?("../../_data")
                 "../../_data"
               elsif Dir.exists?("../_data")
                 "../_data"
               elsif Dir.exists?("_data")
                 "_data"
               else
                 "tree_walk/_data"
               end
  end

  files = [] of String
  find_files(data_dir, files)

  channel = Channel(String).new(500)
  res_channel = Channel(Int32).new(500)
  workers = 8
  wg = WaitGroup.new(workers)

  needle = "category=".to_slice

  workers.times do
    spawn do
      matches = 0
      while file_path = channel.receive?
        File.open(file_path) do |file|
          slice = Bytes.new(file.size)
          file.read_fully(slice)

          i = 0
          limit = slice.size - needle.size
          while i <= limit
            if slice[i, needle.size] == needle
              matches += 1
              i += needle.size
            else
              i += 1
            end
          end
        end
      end
      res_channel.send(matches)
      wg.done
    end
  end

  spawn do
    files.each { |f| channel.send(f) }
    channel.close
  end

  spawn do
    wg.wait
    res_channel.close
  end

  total_matches = 0
  while count = res_channel.receive?
    total_matches += count
  end

  puts "Tree walk complete: files=#{files.size}, matches=#{total_matches}"
end

main
