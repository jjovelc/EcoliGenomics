library(Biostrings)

process_genome <- function(file_path) {
  # Read the FASTA file
  genome <- readDNAStringSet(file_path)
  
  # Get sequence length
  sequence_length <- width(genome)
  
  # Example: Create mock features
  features <- list(
    list(start = 100, end = 500, color = "blue", name = "Feature 1"),
    list(start = 600, end = 900, color = "red", name = "Feature 2")
  )
  
  # Return CGView.js-compatible data
  list(sequenceLength = sequence_length, features = features)
}
