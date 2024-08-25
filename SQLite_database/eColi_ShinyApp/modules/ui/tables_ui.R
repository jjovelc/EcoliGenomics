# modules/ui/tables_ui.R

tables_ui <- function(id) {
  ns <- NS(id)
  
  fluidPage(
    titlePanel("SQLite Database Viewer"),
    sidebarLayout(
      sidebarPanel(
        selectInput(ns("table"), "Choose a table:", choices = NULL)
      ),
      mainPanel(
        DTOutput(ns("table_view")),
        downloadButton(ns("download_csv"), "Download CSV")
      )
    )
  )
}