# app.R

# Source global files
source("global.R")

# Source UI modules
source("modules/ui/tables_ui.R")
source("modules/ui/plots_ui.R")
source("modules/ui/analysis_ui.R")
source("modules/ui/home_ui.R") 

# Source main UI and server
source("ui.R")
source("server.R")

# Run the application
shinyApp(ui = ui, server = server, options = list(width = 1600, height = 1200))