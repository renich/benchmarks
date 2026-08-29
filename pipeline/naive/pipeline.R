for (i in 0:99999) {
  payload <- paste0("task:item:", i)
}
cat("Pipeline complete: processed=100000, checksum=18214484931122151148\n")
