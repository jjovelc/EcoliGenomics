# modules/analysis_ui.R

analysis_ui <- function(id) {
  ns <- NS(id)

  div(class = "dashboardBody",
      h2("Analysis Section"),
      selectInput(ns("analysisType"), "Select Analysis:", choices = c("Summary", "Find Markers")),
      conditionalPanel(
        condition = sprintf("input['%s'] == 'Find Markers'", ns("analysisType")),
        numericInput(ns("n_markers"), "# of markers:", value = 10, min = 1, step = 1),
        helpText("Please enter an integer value.")
      ),
      actionButton(ns("executeAnalysis"), "Execute Analysis"),
      br(),
      br(),
      uiOutput(ns("downloadButtonUI")),  # Dynamic UI for download button
      br(),  # Add some space between button and table
      div(class = "DT-output",
          style = "height: 600px; overflow-y: auto;",
          DTOutput(ns("analysisOutput"))
      )
  )
}