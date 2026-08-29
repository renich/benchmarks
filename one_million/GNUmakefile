SHELL := /bin/bash
.SHELLFLAGS := -euo pipefail -c
.DEFAULT_GOAL := all

.PHONY: all naive optimized clean \
        c.naive cpp.naive crystal.naive go.naive haskell.naive java.naive js.naive nim.naive perl.naive php.naive python3.naive r.naive raku.naive ruby.naive rust.naive \
        c.opt cpp.opt crystal.opt go.opt haskell.opt java.opt js.opt nim.opt perl.opt php.opt python3.opt r.opt raku.opt ruby.opt rust.opt

all: optimized naive

# --- OPTIMIZED (RACE MODE) ---
optimized: c.opt cpp.opt crystal.opt go.opt haskell.opt java.opt js.opt nim.opt perl.opt php.opt python3.opt r.opt raku.opt ruby.opt rust.opt

c.opt:
	@mkdir -p optimized/_build
	clang -O3 -o optimized/_build/bin_c optimized/one_million.c
	time ./optimized/_build/bin_c > /dev/null

cpp.opt:
	@mkdir -p optimized/_build
	clang++ -O3 -o optimized/_build/bin_cpp optimized/one_million.cpp
	time ./optimized/_build/bin_cpp > /dev/null

crystal.opt:
	@mkdir -p optimized/_build
	crystal build --release --no-debug -o optimized/_build/bin_cr optimized/one_million.cr
	time ./optimized/_build/bin_cr > /dev/null

go.opt:
	@mkdir -p optimized/_build
	go build -o optimized/_build/bin_go optimized/one_million.go
	time ./optimized/_build/bin_go > /dev/null

haskell.opt:
	@mkdir -p optimized/_build
	ghc -O2 -v0 -outputdir optimized/_build -o optimized/_build/bin_hs optimized/one_million.hs
	time ./optimized/_build/bin_hs > /dev/null

java.opt:
	@mkdir -p optimized/_build
	javac -d optimized/_build optimized/one_million.java
	time java -cp optimized/_build OneMillion > /dev/null

js.opt:
	time node optimized/one_million.js > /dev/null

nim.opt:
	@mkdir -p optimized/_build
	nim c --cc:clang -d:release --verbosity:0 --hints:off --nimcache:optimized/_build/nimcache -o:optimized/_build/bin_nim optimized/one_million.nim
	time ./optimized/_build/bin_nim > /dev/null

perl.opt:
	time perl optimized/one_million.pl > /dev/null

php.opt:
	time php optimized/one_million.phps > /dev/null

python3.opt:
	time python3 optimized/one_million.py3 > /dev/null

r.opt:
	time Rscript optimized/one_million.R > /dev/null

raku.opt:
	time rakudo optimized/one_million.p6 > /dev/null

ruby.opt:
	time ruby optimized/one_million.rb > /dev/null

rust.opt:
	@mkdir -p optimized/_build
	rustc -O -o optimized/_build/bin_rust optimized/one_million.rs
	time ./optimized/_build/bin_rust > /dev/null

# --- NAIVE (OUT-OF-THE-BOX MODE) ---
naive: c.naive cpp.naive crystal.naive go.naive haskell.naive java.naive js.naive nim.naive perl.naive php.naive python3.naive r.naive raku.naive ruby.naive rust.naive

c.naive:
	@mkdir -p naive/_build
	clang -O3 -o naive/_build/bin_c naive/one_million.c
	time ./naive/_build/bin_c > /dev/null

cpp.naive:
	@mkdir -p naive/_build
	clang++ -O3 -o naive/_build/bin_cpp naive/one_million.cpp
	time ./naive/_build/bin_cpp > /dev/null

crystal.naive:
	@mkdir -p naive/_build
	crystal build --release --no-debug -o naive/_build/bin_cr naive/one_million.cr
	time ./naive/_build/bin_cr > /dev/null

go.naive:
	@mkdir -p naive/_build
	go build -o naive/_build/bin_go naive/one_million.go
	time ./naive/_build/bin_go > /dev/null

haskell.naive:
	@mkdir -p naive/_build
	ghc -O2 -v0 -outputdir naive/_build -o naive/_build/bin_hs naive/one_million.hs
	time ./naive/_build/bin_hs > /dev/null

java.naive:
	@mkdir -p naive/_build
	javac -d naive/_build naive/one_million.java
	time java -cp naive/_build OneMillion > /dev/null

js.naive:
	time node naive/one_million.js > /dev/null

nim.naive:
	@mkdir -p naive/_build
	nim c --cc:clang -d:release --verbosity:0 --hints:off --nimcache:naive/_build/nimcache -o:naive/_build/bin_nim naive/one_million.nim
	time ./naive/_build/bin_nim > /dev/null

perl.naive:
	time perl naive/one_million.pl > /dev/null

php.naive:
	time php naive/one_million.phps > /dev/null

python3.naive:
	time python3 naive/one_million.py3 > /dev/null

r.naive:
	time Rscript naive/one_million.R > /dev/null

raku.naive:
	time rakudo naive/one_million.p6 > /dev/null

ruby.naive:
	time ruby naive/one_million.rb > /dev/null

rust.naive:
	@mkdir -p naive/_build
	rustc -O -o naive/_build/bin_rust naive/one_million.rs
	time ./naive/_build/bin_rust > /dev/null

clean:
	rm -rf naive/_build optimized/_build
