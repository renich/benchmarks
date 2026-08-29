data_dir <- if (dir.exists("tree_walk/_data")) "tree_walk/_data" else if (dir.exists("../../_data")) "../../_data" else if (dir.exists("../_data")) "../_data" else "_data"
files <- list.files(data_dir, pattern = "\\.txt$", recursive = TRUE, full.names = TRUE)

total_matches <- 0
for (f in files) {
  text <- readChar(f, file.info(f)$size, useBytes = TRUE)
  # count occurrences of category=
  m <- gregexpr("category=", text, fixed = TRUE)[[1]]
  if (m[1] != -1) {
    total_matches <- total_matches + length(m)
  }
}

cat(sprintf("Tree walk complete: files=%d, matches=%d\n", length(files), total_matches))
