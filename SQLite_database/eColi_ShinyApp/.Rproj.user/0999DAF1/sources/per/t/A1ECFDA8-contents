

tables_server <- function(input, output, session, con, tables) {
  # Reactive expression to get the selected table data
  table_data <- reactive({
    req(input$table)
    tryCatch({
      dbReadTable(con, input$table)
    }, error = function(e) {
      showNotification(paste("Error reading table:", e$message), type = "error")
      return(NULL)
    })
  })
  
  # Update the choices for the selectInput
  observe({
    updateSelectInput(session, "table", choices = tables)
  })
  
  # Render the DataTable
  output$table_view <- renderDT({
    datatable(table_data(), 
              extensions = 'Buttons', 
              options = list(
                dom = 'Bfrtip',
                buttons = c('copy', 'csv', 'excel', 'pdf', 'print')
              ))
  })
  
  # Download handler for CSV
  output$download_csv <- downloadHandler(
    filename = function() {
      paste(input$table, ".csv", sep = "")
    },
    content = function(file) {
      write.csv(table_data(), file, row.names = FALSE)
    }
  )
}