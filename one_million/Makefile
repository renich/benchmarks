all: c.result cpp.result crystal.result go.result java.result javascript.result perl.result php.result python.result python3.result rakudo.result ruby.result rust.result nim.result

c.result: one_million.c
	clang -o one_million_c one_million.c > /dev/null
	time ./one_million_c > /dev/null
	echo

cpp.result: one_million.cpp
	clang++ -o one_million_cpp one_million.cpp > /dev/null
	time ./one_million_cpp > /dev/null
	clang++ -o one_million_ash_cpp one_million_ash.cpp > /dev/null
	time ./one_million_ash_cpp > /dev/null
	echo

crystal.result: one_million.cr
	crystal build --release -o one_million_cr one_million.cr
	time ./one_million_cr > /dev/null
	echo

go.result: one_million.go
	go build -o one_million_go one_million.go
	time ./one_million_go > /dev/null
	echo

java.result: one_million.java
	javac one_million.java
	time java OneMillion > /dev/null
	echo

javascript.result: one_million.js
	time node one_million.js > /dev/null
	echo

perl.result: one_million.pl
	time perl one_million.pl > /dev/null
	echo

php.result: one_million.phps
	time php one_million.phps > /dev/null
	echo

python.result: one_million.py
	time python2 one_million.py > /dev/null
	echo

python3.result: one_million.py3
	time python3 one_million.py3 > /dev/null
	echo

rakudo.result: one_million.p6
	time perl6 one_million.p6 > /dev/null

ruby.result: one_million.rb
	time ruby one_million.rb > /dev/null
	echo

rust.result: one_million.rs
	rustc -o one_million_rust one_million.rs > /dev/null
	time ./one_million_rust > /dev/null

nim.result: one_million.nim
	nim c --cc:clang -d:danger --verbosity:0 --hints:off -o:one_million_nim one_million.nim
	time ./one_million_nim > /dev/null

clean:
	rm -f one_million_c one_million_cpp one_million_cr one_million_go OneMillion.class one_million_rust one_million_ash_cpp
