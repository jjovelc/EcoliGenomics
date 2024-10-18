# modules/server/plots_server.R

library(shiny)
library(DBI)
library(ggplot2)
library(reshape2)
library(RColorBrewer)

plots_server <- function(input, output, session) {
  # Load database connection from global environment
  con <- get("con", envir = .GlobalEnv)
  req(con)
  
  # Reactive expression to generate the AMR pivot table when the plot button is clicked
  amr_data <- eventReactive(input$plot, {
    req(input$table_select)
    
    # Determine the appropriate columns based on the selected table
    gene_column <- if (input$table_select == "resFinder_results") "resistance_gene" else "gene"
    
    # SQL query to select necessary columns
    query <- paste0("SELECT sample_id, ", gene_column, " FROM ", input$table_select)
    
    # Read data into a data frame
    df <- dbGetQuery(con, query)
    
    # Debugging: Print the first few rows of the fetched data
    print("Fetched Data:")
    print(head(df))
    
    # Check if the dataframe is empty
    if (nrow(df) == 0) {
      showNotification("No data available for the selected table.", type = "warning")
      return(NULL)
    }
    
    # Rename columns to have consistent names for plotting
    colnames(df) <- c("sample_id", "gene")
    
    # Create a pivot table with gene as rows and sample_id as columns
    pivot_df <- reshape2::dcast(df, gene ~ sample_id, fun.aggregate = length, value.var = "gene", fill = 0)
    
    # Debugging: Print the first few rows of the pivot table
    print("Pivot Table:")
    print(head(pivot_df))
    
    return(pivot_df)
  })
  
  # Reactive expression to get sample metadata
  sample_metadata <- reactive({
    query <- "SELECT * FROM samples"
    metadata <- dbGetQuery(con, query)
    
    # Debugging: Print the first few rows of the metadata
    print("Sample Metadata:")
    print(head(metadata))
    
    return(metadata)
  })
  
  # Render the static heatmap using ggplot2
  output$amr_heatmap <- renderPlot({
    pivot_df <- amr_data()
    if (is.null(pivot_df)) return(NULL)
    
    metadata <- sample_metadata()
    
    # Melt the pivot table for ggplot
    melted_data <- reshape2::melt(pivot_df, id.vars = 'gene')
    colnames(melted_data) <- c('AMR', 'Sample', 'Count')
    
    # Debugging: Print the first few rows of the melted data
    print("Melted Data:")
    print(head(melted_data))
    
    # Merge metadata with melted data using 'Sample' and 'sample_id'
    melted_data <- merge(melted_data, metadata, by.x = "Sample", by.y = "sample_id", all.x = TRUE)
    
    # Debugging: Print the first few rows after merging
    print("Merged Data:")
    print(head(melted_data))
    
    # Check if merged data is empty
    if (nrow(melted_data) == 0) {
      showNotification("No data available after merging with metadata.", type = "warning")
      return(NULL)
    }
    
    # Ensure the Sample factor levels are in the sorted order
    melted_data$Sample <- factor(melted_data$Sample, levels = unique(melted_data$Sample))
    
    # Create a color palette for the 'source' using RColorBrewer
    unique_sources <- unique(melted_data$source)
    source_colors <- setNames(RColorBrewer::brewer.pal(min(8, length(unique_sources)), "Dark2"), unique_sources)
    
    # Create a color palette for the 'mash_group' using RColorBrewer
    unique_mash_groups <- unique(melted_data$mash_group)
    mash_group_colors <- setNames(RColorBrewer::brewer.pal(min(8, length(unique_mash_groups)), "Set3"), unique_mash_groups)
    
    # Create the static heatmap for AMR counts using ggplot2
    heatmap <- ggplot(melted_data, aes(x = Sample, y = AMR, fill = as.factor(Count))) +
      geom_tile(color = "gray") +
      scale_fill_manual(values = c("0" = "white", "1" = "dodgerblue1", "2" = "red", "3" = "limegreen", "4" = "black"),
                        name = "Count") +
      theme_minimal() +
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
        axis.text.y = element_text(size = 10),
        axis.title.x = element_text(size = 12),
        axis.title.y = element_text(size = 12),
        legend.position = "right"
      ) +
      labs(x = "Sample", y = "Resistance Genes", title = "AMR Abundance Heatmap")
    
    # Display the plot
    print(heatmap)
  })
  
  # Download handler for the static plot
  output$download_plot <- downloadHandler(
    filename = function() {
      paste("amr_heatmap", Sys.Date(), ".png", sep = "")
    },
    content = function(file) {
      pivot_df <- amr_data()
      if (is.null(pivot_df)) {
        showNotification("No plot available to download.", type = "error")
        return(NULL)
      }
      
      metadata <- sample_metadata()
      
      melted_data <- reshape2::melt(pivot_df, id.vars = 'gene')
      colnames(melted_data) <- c('AMR', 'Sample', 'Count')
      
      melted_data <- merge(melted_data, metadata, by.x = "Sample", by.y = "sample_id", all.x = TRUE)
      
      if (nrow(melted_data) == 0) {
        showNotification("No data available for download after merging with metadata.", type = "warning")
        return(NULL)
      }
      
      melted_data$Sample <- factor(melted_data$Sample, levels = unique(melted_data$Sample))
      
      heatmap <- ggplot(melted_data, aes(x = Sample, y = AMR, fill = as.factor(Count))) +
        geom_tile(color = "gray") +
        scale_fill_manual(values = c("0" = "white", "1" = "dodgerblue1", "2" = "red", "3" = "limegreen", "4" = "black"),
                          name = "Count") +
        theme_minimal() +
        theme(
          axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
          axis.text.y = element_text(size = 10),
          axis.title.x = element_text(size = 12),
          axis.title.y = element_text(size = 12),
          legend.position = "right"
        ) +
        labs(x = "Sample", y = "Resistance Genes", title = "AMR Abundance Heatmap")
      
      ggsave(file, plot = heatmap, width = 15, height = 10, dpi = 300)
    }
  )
}

# modules/ui/plots_ui.R

plots_ui <- function(id) {
  ns <- NS(id)
  
  fluidPage(
    sidebarLayout(
      sidebarPanel(
        selectInput(ns("table_select"), "Select Table:", choices = c("resFinder_results", "another_table")),
        actionButton(ns("plot"), "Generate Plot"),
        downloadButton(ns("download_plot"), "Download Plot")
      ),
      mainPanel(
        plotOutput(ns("amr_heatmap"))
      )
    )
  )
}
 