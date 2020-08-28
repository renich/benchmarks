# Compile command:
# nim c --cc:clang -d:danger one_million.nim

for n in 0 ..< 1_000_000:
  echo "Hello, this is iteration number: ", n
