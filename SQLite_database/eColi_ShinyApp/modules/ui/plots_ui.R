# modules/ui/plots_ui.R
source("global.R")

plots_ui <- function(id) {
  ns <- NS(id)
  fluidPage(
    titlePanel("Feature Tilemap"),
    sidebarLayout(
      sidebarPanel(
        selectInput(ns("table_select"), "Select Table:", choices = c("resFinder_results", "amrp_results", "amrcore_results")),
        actionButton(ns("plot"), "Generate Plot"),
        downloadButton(ns("download_plot"), "Download Plot"),
        downloadButton(ns("download_data"), "Download Data")
      ),
      mainPanel(
        div(
          #style = "position: relative; overflow: visible;",
          div(
            style = "width: 100%; height: 600px; overflow-x: scroll; overflow-y: visible",
            girafeOutput(ns("amr_tilemap"), width = "1000px", height = "800px")  # Increase height if needed
          )
        )
      )
    )
  )
}