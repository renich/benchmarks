const fs = require("fs");
const path = require("path");

function findFiles(dir, list = []) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      findFiles(fullPath, list);
    } else if (entry.name.endsWith(".txt")) {
      list.push(fullPath);
    }
  }
  return list;
}

function main() {
  let dataDir = "tree_walk/_data";
  if (!fs.existsSync(dataDir)) {
    if (fs.existsSync("../../_data")) dataDir = "../../_data";
    else if (fs.existsSync("../_data")) dataDir = "../_data";
    else if (fs.existsSync("_data")) dataDir = "_data";
  }

  const files = findFiles(dataDir);
  let totalMatches = 0;
  const needle = Buffer.from("category=", "ascii");

  for (const f of files) {
    const buf = fs.readFileSync(f);
    let pos = 0;
    while ((pos = buf.indexOf(needle, pos)) !== -1) {
      totalMatches++;
      pos += 9;
    }
  }

  console.log(`Tree walk complete: files=${files.length}, matches=${totalMatches}`);
}

main();
