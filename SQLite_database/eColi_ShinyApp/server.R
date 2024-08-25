# server.R

# Source server modules
source("modules/server/tables_server.R")
source("modules/server/plots_server.R")
source("modules/server/analysis_server.R")

server <- function(input, output, session) {
  # Connect to your SQLite database
  con <- dbConnect(RSQLite::SQLite(), "/Users/juanjovel/OneDrive/jj/UofC/data_analysis/sylviaCheckley/alyssaButters/eColi_genomics/SQLite_database/Ecoli.db")
  
  # Close the connection when the session ends
  onSessionEnded(function() {
    dbDisconnect(con)
  })
  
  # Get list of tables in the database
  tables <- dbListTables(con)
  
  # Call module server functions
  callModule(plots_server, "plots")
  callModule(tables_server, "tables", con = con, tables = tables)
  callModule(analysis_server, "analysis")
}

