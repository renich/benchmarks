import std/[os, strutils]

proc findFiles(dir: string): seq[string] =
  result = @[]
  if dirExists(dir):
    for path in walkDirRec(dir):
      if path.endsWith(".txt"):
        result.add(path)

proc main() =
  var dataDir = "tree_walk/_data"
  if not dirExists(dataDir):
    if dirExists("../../_data"): dataDir = "../../_data"
    elif dirExists("../_data"): dataDir = "../_data"
    elif dirExists("_data"): dataDir = "_data"

  let files = findFiles(dataDir)
  var totalMatches = 0
  let needle = "category="

  for f in files:
    let content = readFile(f)
    var pos = 0
    while true:
      let found = content.find(needle, pos)
      if found == -1: break
      inc(totalMatches)
      pos = found + 9

  echo "Tree walk complete: files=" & $files.len & ", matches=" & $totalMatches

main()
