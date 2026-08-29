SHELL := /bin/bash
.SHELLFLAGS := -euo pipefail -c
.DEFAULT_GOAL := all

.PHONY: all naive optimized clean setup \
        c.naive cpp.naive crystal.naive go.naive haskell.naive java.naive js.naive nim.naive perl.naive php.naive python3.naive r.naive raku.naive ruby.naive rust.naive \
        c.opt cpp.opt crystal.opt go.opt haskell.opt java.opt js.opt nim.opt perl.opt php.opt python3.opt r.opt raku.opt ruby.opt rust.opt

setup:
	@mkdir -p _data
	python3 ../tools/gen_tree.py --output _data --files 2500

all: optimized naive

# --- OPTIMIZED (RACE MODE) ---
optimized: c.opt cpp.opt crystal.opt go.opt haskell.opt java.opt js.opt nim.opt perl.opt php.opt python3.opt r.opt raku.opt ruby.opt rust.opt

c.opt:
	@mkdir -p optimized/_build
	clang -O3 -pthread -o optimized/_build/bin_c optimized/tree_walk.c
	time ./optimized/_build/bin_c > /dev/null

cpp.opt:
	@mkdir -p optimized/_build
	clang++ -O3 -std=c++20 -pthread -o optimized/_build/bin_cpp optimized/tree_walk.cpp
	time ./optimized/_build/bin_cpp > /dev/null

crystal.opt:
	@mkdir -p optimized/_build
	crystal build --release --no-debug -o optimized/_build/bin_cr optimized/tree_walk.cr
	time ./optimized/_build/bin_cr > /dev/null

go.opt:
	@mkdir -p optimized/_build
	go build -o optimized/_build/bin_go optimized/tree_walk.go
	time ./optimized/_build/bin_go > /dev/null

haskell.opt:
	@mkdir -p optimized/_build
	ghc -O2 -v0 -outputdir optimized/_build -o optimized/_build/bin_hs optimized/tree_walk.hs
	time ./optimized/_build/bin_hs > /dev/null

java.opt:
	@mkdir -p optimized/_build
	javac -d optimized/_build optimized/TreeWalk.java
	time java -cp optimized/_build TreeWalk > /dev/null

js.opt:
	time node optimized/tree_walk.js > /dev/null

nim.opt:
	@mkdir -p optimized/_build
	nim c --cc:clang -d:release --verbosity:0 --hints:off --nimcache:optimized/_build/nimcache -o:optimized/_build/bin_nim optimized/tree_walk.nim
	time ./optimized/_build/bin_nim > /dev/null

perl.opt:
	time perl optimized/tree_walk.pl > /dev/null

php.opt:
	time php optimized/tree_walk.phps > /dev/null

python3.opt:
	time python3 optimized/tree_walk.py3 > /dev/null

r.opt:
	time Rscript optimized/tree_walk.R > /dev/null

raku.opt:
	time rakudo optimized/tree_walk.p6 > /dev/null

ruby.opt:
	time ruby optimized/tree_walk.rb > /dev/null

rust.opt:
	@mkdir -p optimized/_build
	rustc -O -o optimized/_build/bin_rust optimized/tree_walk.rs
	time ./optimized/_build/bin_rust > /dev/null

# --- NAIVE (OUT-OF-THE-BOX MODE) ---
naive: c.naive cpp.naive crystal.naive go.naive haskell.naive java.naive js.naive nim.naive perl.naive php.naive python3.naive r.naive raku.naive ruby.naive rust.naive

c.naive:
	@mkdir -p naive/_build
	clang -O3 -pthread -o naive/_build/bin_c naive/tree_walk.c
	time ./naive/_build/bin_c > /dev/null

cpp.naive:
	@mkdir -p naive/_build
	clang++ -O3 -std=c++20 -pthread -o naive/_build/bin_cpp naive/tree_walk.cpp
	time ./naive/_build/bin_cpp > /dev/null

crystal.naive:
	@mkdir -p naive/_build
	crystal build --release --no-debug -o naive/_build/bin_cr naive/tree_walk.cr
	time ./naive/_build/bin_cr > /dev/null

go.naive:
	@mkdir -p naive/_build
	go build -o naive/_build/bin_go naive/tree_walk.go
	time ./naive/_build/bin_go > /dev/null

haskell.naive:
	@mkdir -p naive/_build
	ghc -O2 -v0 -outputdir naive/_build -o naive/_build/bin_hs naive/tree_walk.hs
	time ./naive/_build/bin_hs > /dev/null

java.naive:
	@mkdir -p naive/_build
	javac -d naive/_build naive/TreeWalk.java
	time java -cp naive/_build TreeWalk > /dev/null

js.naive:
	time node naive/tree_walk.js > /dev/null

nim.naive:
	@mkdir -p naive/_build
	nim c --cc:clang -d:release --verbosity:0 --hints:off --nimcache:naive/_build/nimcache -o:naive/_build/bin_nim naive/tree_walk.nim
	time ./naive/_build/bin_nim > /dev/null

perl.naive:
	time perl naive/tree_walk.pl > /dev/null

php.naive:
	time php naive/tree_walk.phps > /dev/null

python3.naive:
	time python3 naive/tree_walk.py3 > /dev/null

r.naive:
	time Rscript naive/tree_walk.R > /dev/null

raku.naive:
	time rakudo naive/tree_walk.p6 > /dev/null

ruby.naive:
	time ruby naive/tree_walk.rb > /dev/null

rust.naive:
	@mkdir -p naive/_build
	rustc -O -o naive/_build/bin_rust naive/tree_walk.rs
	time ./naive/_build/bin_rust > /dev/null

clean:
	rm -rf naive/_build optimized/_build _data
