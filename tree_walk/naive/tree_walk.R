data_dir <- if (dir.exists("tree_walk/_data")) "tree_walk/_data" else if (dir.exists("../../_data")) "../../_data" else if (dir.exists("../_data")) "../_data" else "_data"
files <- list.files(data_dir, pattern = "\\.txt$", recursive = TRUE, full.names = TRUE)

total_matches <- 0
for (f in files) {
  lines <- readLines(f, warn = FALSE)
  matches <- grep("category=[A-Z_]+", lines)
  total_matches <- total_matches + length(matches)
}

cat(sprintf("Tree walk complete: files=%d, matches=%d\n", length(files), total_matches))
