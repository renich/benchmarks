all: c.result crystal.result perl.result php.result python.result python3.result ruby.result

c.result: one_million.c
	gcc -o one_million_c one_million.c &> /dev/null
	time ./one_million_c &> /dev/null
	echo

crystal.result: one_million.cr
	crystal build --release -o one_million_cr one_million.cr
	time ./one_million_cr &> /dev/null

go.result: one_million.go
	go build -o one_million_go one_million.go
	time ./one_million_go &> /dev/null

perl.result: one_million.pl
	time perl one_million.pl &> /dev/null
	echo

php.result: one_million.phps
	time php-cgi one_million.phps &> /dev/null
	echo

python.result: one_million.py
	time python2 one_million.py &> /dev/null
	echo

python3.result: one_million.py3
	time python3 one_million.py3 &> /dev/null
	echo

ruby.result: one_million.rb
	time ruby one_million.rb &> /dev/null
	echo

clean:
	rm -f one_million_c one_million_cr one_million_go
