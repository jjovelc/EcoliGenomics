# modules/ui/tables_ui.R

tables_ui <- function(id) {
  ns <- NS(id)
  
  fluidPage(
    tags$style(HTML("
      body, label, input, select, button {
        color: black !important;
      }
    ")),
    titlePanel("SQLite Database Viewer"),
    sidebarLayout(
      sidebarPanel(
        selectInput(ns("table"), "Choose a table:", choices = NULL),          # Table selection
        textInput(ns("sample_id"), "Enter Sample ID (optional):"),            # Sample ID filter
        textInput(ns("gene_symbol"), "Enter Gene Symbol (optional):"),        # Gene symbol filter
        textAreaInput(ns("custom_query"), "Enter Custom SQL Query (optional):", "", rows = 4), # Custom SQL query input
        actionButton(ns("query"), "Query Database"),                          # Query button
        downloadButton(ns("download_csv"), "Download CSV")
      ),
      mainPanel(
        DTOutput(ns("table_view")) 
      )
    )
  )
}