# tables_server.R

source("global.R")

tables_server <- function(input, output, session, con, tables) {
  ns <- session$ns  # Namespacing for module inputs and outputs
  
  # Update the choices for the table selectInput
  observe({
    updateSelectInput(session, "table", choices = tables)
  })
  
  # Dynamic UI for column selection based on selected table
  output$column_selector <- renderUI({
    req(input$table)
    # Get the column names for the selected table
    columns <- dbListFields(con, input$table)
    # Create the selectInput for columns
    selectInput(ns("column"), "Choose a column to search:", choices = columns)
  })
  
  # Reactive expression to get the selected table data or execute custom SQL
  table_data <- reactive({
    req(input$query)  # Ensure this runs only when the button is clicked
    
    # Get the custom query entered by the user
    custom_query <- input$custom_query
    
    if (custom_query != "") {
      # Handle special meta-commands separately
      if (grepl("^\\.tables$", custom_query)) {
        # Return list of tables
        tables <- dbListTables(con)
        return(data.frame(Tables = tables))
        
      } else if (grepl("^\\.schema (\\w+)$", custom_query, perl = TRUE)) {
        # Extract the table name
        table_name <- sub("^\\.schema (\\w+)$", "\\1", custom_query)
        # Get table schema
        query <- paste0("PRAGMA table_info(", table_name, ");")
        return(dbGetQuery(con, query))
        
      } else {
        # Execute standard SQL queries
        tryCatch({
          return(dbGetQuery(con, custom_query))
        }, error = function(e) {
          showNotification(paste("Error executing custom query:", e$message), type = "error")
          return(NULL)
        })
      }
    }
    
    # If no custom query is provided, proceed with the default logic
    req(input$table)
    
    # Get the base query for the selected table
    query <- paste0("SELECT * FROM ", dbQuoteIdentifier(con, input$table))
    
    # Build conditions
    conditions <- list()
    
    # Add condition for the selected column and search value
    if (!is.null(input$column) && input$search_value != "") {
      column_name <- dbQuoteIdentifier(con, input$column)
      search_value <- dbQuoteString(con, input$search_value)
      conditions <- c(conditions, paste0(column_name, " = ", search_value))
    }
    
    # Append conditions to the query if any
    if (length(conditions) > 0) {
      query <- paste0(query, " WHERE ", paste(conditions, collapse = " AND "))
    }
    
    # Execute the query
    tryCatch({
      dbGetQuery(con, query)
    }, error = function(e) {
      showNotification(paste("Error executing query:", e$message), type = "error")
      return(NULL)
    })
  })
  
  # Render the DataTable with query results
  output$table_view <- renderDT({
    req(table_data())  # Ensure table_data is available
    datatable(table_data(), 
              extensions = 'Buttons', 
              options = list(
                dom = 'Bfrtip',
                buttons = c('copy', 'csv', 'excel', 'pdf', 'print'),
                scrollX = TRUE,            # Enable horizontal scrolling
                scrollY = '400px',         # Set a specific height for vertical scrolling
                paging = TRUE,             # Enable paging
                pageLength = 10            # Number of rows per page
              ))
  })
  
  # Download handler for CSV
  output$download_csv <- downloadHandler(
    filename = function() {
      paste(input$table, "_query_results.csv", sep = "")
    },
    content = function(file) {
      write.csv(table_data(), file, row.names = FALSE)
    }
  )
}