#!/usr/bin/env crystal

# https://github.com/crystal-lang/crystal/pull/8935
STDOUT.flush_on_newline = false
STDOUT.sync = false

1_000_000.times do |number|
	print "Hello, this is iteration number: ", number, "\n"
end
