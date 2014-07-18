all: c.result perl.result php.result python.result python3.result ruby.result

c.result: one_million.c
	gcc -O9 -o one_million one_million.c &> /dev/null
	time ./one_million &> /dev/null
	echo

perl.result: one_million.pl
	time perl one_million.pl &> /dev/null
	echo

php.result: one_million.phps
	time php-cgi one_million.phps &> /dev/null
	echo

python.result: one_million.py
	time python one_million.py &> /dev/null
	echo

python3.result: one_million.py3
	time python3 one_million.py3 &> /dev/null
	echo

ruby.result: one_million.rb
	time ruby one_million.rb &> /dev/null
	echo

clean:
	rm -f one_million
