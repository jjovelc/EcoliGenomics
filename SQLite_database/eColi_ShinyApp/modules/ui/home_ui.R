# In modules/home_ui.R

home_ui <- function(id) {
  ns <- NS(id)  # Create the namespacing function for the UI
  tagList(
    div(
      style = "width: 160%; height: 1000px; overflow-y: auto; overflow-x: auto;",  # Set size and scroll properties
      includeMarkdown("home.md")
    )
    
  )
}

