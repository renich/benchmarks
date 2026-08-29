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
	clang -O3 -pthread -o optimized/_build/bin_c optimized/pipeline.c
	time ./optimized/_build/bin_c > /dev/null

cpp.opt:
	@mkdir -p optimized/_build
	clang++ -O3 -std=c++20 -pthread -o optimized/_build/bin_cpp optimized/pipeline.cpp
	time ./optimized/_build/bin_cpp > /dev/null

crystal.opt:
	@mkdir -p optimized/_build
	crystal build --release -Dpreview_mt --no-debug -o optimized/_build/bin_cr optimized/pipeline.cr
	CRYSTAL_WORKERS=8 time ./optimized/_build/bin_cr > /dev/null

go.opt:
	@mkdir -p optimized/_build
	go build -o optimized/_build/bin_go optimized/pipeline.go
	time ./optimized/_build/bin_go > /dev/null

haskell.opt:
	@mkdir -p optimized/_build
	ghc -O2 -v0 -outputdir optimized/_build -o optimized/_build/bin_hs optimized/pipeline.hs
	time ./optimized/_build/bin_hs > /dev/null

java.opt:
	@mkdir -p optimized/_build
	javac -d optimized/_build optimized/Pipeline.java
	time java -cp optimized/_build Pipeline > /dev/null

js.opt:
	time node optimized/pipeline.js > /dev/null

nim.opt:
	@mkdir -p optimized/_build
	nim c --cc:clang -d:release --verbosity:0 --hints:off --nimcache:optimized/_build/nimcache -o:optimized/_build/bin_nim optimized/pipeline.nim
	time ./optimized/_build/bin_nim > /dev/null

perl.opt:
	time perl optimized/pipeline.pl > /dev/null

php.opt:
	time php optimized/pipeline.phps > /dev/null

python3.opt:
	time python3 optimized/pipeline.py3 > /dev/null

r.opt:
	time Rscript optimized/pipeline.R > /dev/null

raku.opt:
	time rakudo optimized/pipeline.p6 > /dev/null

ruby.opt:
	time ruby optimized/pipeline.rb > /dev/null

rust.opt:
	@mkdir -p optimized/_build
	rustc -O -o optimized/_build/bin_rust optimized/pipeline.rs
	time ./optimized/_build/bin_rust > /dev/null

# --- NAIVE (OUT-OF-THE-BOX MODE) ---
naive: c.naive cpp.naive crystal.naive go.naive haskell.naive java.naive js.naive nim.naive perl.naive php.naive python3.naive r.naive raku.naive ruby.naive rust.naive

c.naive:
	@mkdir -p naive/_build
	clang -O3 -pthread -o naive/_build/bin_c naive/pipeline.c
	time ./naive/_build/bin_c > /dev/null

cpp.naive:
	@mkdir -p naive/_build
	clang++ -O3 -std=c++20 -pthread -o naive/_build/bin_cpp naive/pipeline.cpp
	time ./naive/_build/bin_cpp > /dev/null

crystal.naive:
	@mkdir -p naive/_build
	crystal build --release --no-debug -o naive/_build/bin_cr naive/pipeline.cr
	time ./naive/_build/bin_cr > /dev/null

go.naive:
	@mkdir -p naive/_build
	go build -o naive/_build/bin_go naive/pipeline.go
	time ./naive/_build/bin_go > /dev/null

haskell.naive:
	@mkdir -p naive/_build
	ghc -O2 -v0 -outputdir naive/_build -o naive/_build/bin_hs naive/pipeline.hs
	time ./naive/_build/bin_hs > /dev/null

java.naive:
	@mkdir -p naive/_build
	javac -d naive/_build naive/Pipeline.java
	time java -cp naive/_build Pipeline > /dev/null

js.naive:
	time node naive/pipeline.js > /dev/null

nim.naive:
	@mkdir -p naive/_build
	nim c --cc:clang -d:release --verbosity:0 --hints:off --nimcache:naive/_build/nimcache -o:naive/_build/bin_nim naive/pipeline.nim
	time ./naive/_build/bin_nim > /dev/null

perl.naive:
	time perl naive/pipeline.pl > /dev/null

php.naive:
	time php naive/pipeline.phps > /dev/null

python3.naive:
	time python3 naive/pipeline.py3 > /dev/null

r.naive:
	time Rscript naive/pipeline.R > /dev/null

raku.naive:
	time rakudo naive/pipeline.p6 > /dev/null

ruby.naive:
	time ruby naive/pipeline.rb > /dev/null

rust.naive:
	@mkdir -p naive/_build
	rustc -O -o naive/_build/bin_rust naive/pipeline.rs
	time ./naive/_build/bin_rust > /dev/null

clean:
	rm -rf naive/_build optimized/_build
