# app.R

## Is desired (perhaps is convenient)
#  merge this script with main UI and server

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
shinyApp(ui = ui, server = server)
