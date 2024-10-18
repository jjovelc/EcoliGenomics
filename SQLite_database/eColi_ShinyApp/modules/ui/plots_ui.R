# modules/ui/plots_ui.R

source("global.R")
library(shiny)

plots_ui <- function(id) {
  ns <- NS(id)
  
  fluidPage(
    sidebarLayout(
      sidebarPanel(
        selectInput(ns("table_select"), "Select Table:", choices = c("resFinder_results", "another_table")),
        actionButton(ns("plot"), "Generate Plot"),
        downloadButton(ns("download_plot"), "Download Plot")  # Namespaced download button
      ),
      mainPanel(
        # Scrollable container for the plot
        div(
          style = "overflow: auto; width: 100%; height: 800px; border: 1px solid #ccc; padding: 10px;",
          plotOutput(ns("amr_heatmap"), height = "1600px", width = "1600px")  # Namespaced plotOutput with larger dimensions
        )
        # Removed the duplicate downloadButton from mainPanel
      )
    )
  )
}