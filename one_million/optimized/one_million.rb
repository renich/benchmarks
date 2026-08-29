#!/usr/bin/env ruby

$stdout.sync = false
prefix = "Hello, this is iteration number: ".freeze
chunk = String.new(capacity: 65536)

1_000_000.times do |n|
  chunk << prefix << n.to_s << "\n"
  if chunk.bytesize >= 60000
    $stdout.write(chunk)
    chunk.clear
  end
end

$stdout.write(chunk) unless chunk.empty?
