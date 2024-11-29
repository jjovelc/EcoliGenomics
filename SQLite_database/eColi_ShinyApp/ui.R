# ui.R

source("modules/ui/tables_ui.R")
source("modules/ui/home_ui.R")
source("modules/ui/plots_ui.R")
source("modules/ui/bgviewer_ui.R")
source("modules/ui/analysis_ui.R")

source("globals.R")

ui <- fluidPage(
  theme = shinytheme("flatly"),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),
  div(class = "navbar-fixed-top",
      navbarPage(
        title = "Checkley Lab's Data Explorer",
        tabPanel("Home", home_ui("home")),
        tabPanel("Tables", tables_ui("tables")),
        tabPanel("Plots", plots_ui("plots")),
        tabPanel("BGviewer", bgviewer_ui("bgviewer")),
        tabPanel("Analysis", analysis_ui("analysis"))
        
      )
  )
)
