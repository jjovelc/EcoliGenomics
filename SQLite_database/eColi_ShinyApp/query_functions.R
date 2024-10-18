# Function to query the database
query_table <- function(table_name, conn, sample_id = NULL, gene_symbol = NULL) {
  # Construct SQL query with optional filtering
  query <- paste0("SELECT * FROM ", table_name)
  
  conditions <- list()
  if (!is.null(sample_id)) {
    conditions <- c(conditions, paste0("sample_id = '", sample_id, "'"))
  }
  if (!is.null(gene_symbol)) {
    conditions <- c(conditions, paste0("gene_symbol = '", gene_symbol, "'"))
  }
  
  if (length(conditions) > 0) {
    query <- paste0(query, " WHERE ", paste(conditions, collapse = " AND "))
  }
  
  # Execute the query
  result <- dbGetQuery(conn, query)
  return(result)
}
