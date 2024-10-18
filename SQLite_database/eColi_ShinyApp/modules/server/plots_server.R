source("global.R")

library(shiny)
library(DBI)
library(ggplot2)
library(reshape2)
library(RColorBrewer)
library(patchwork)

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
    
    # Handle missing columns gracefully
    if (!"source" %in% colnames(metadata)) {
      metadata$source <- "Unknown"
    }
    if (!"mash_group" %in% colnames(metadata)) {
      metadata$mash_group <- "Unknown"
    }
    
    return(metadata)
  })
  
  # Function to generate the combined plot with adjustable heights
  generate_combined_plot <- function(for_download = FALSE) {
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
    
    melted_data <- melted_data %>%
      arrange(source, Sample)  # First by 'source', then by 'Sample' within each 'source'
    
    
    
    # Ensure the Sample factor levels are in the sorted order
    melted_data$Sample <- factor(melted_data$Sample, levels = unique(melted_data$Sample))
    
    # Create a color palette for the 'source' using RColorBrewer
    unique_sources <- unique(melted_data$source)
    source_colors <- setNames(
      RColorBrewer::brewer.pal(min(8, length(unique_sources)), "Dark2"),
      unique_sources
    )
    
    # Create a color palette for the 'mash_group' using RColorBrewer
    unique_mash_groups <- unique(melted_data$mash_group)
    mash_group_colors <- setNames(
      RColorBrewer::brewer.pal(min(8, length(unique_mash_groups)), "Set3"),
      unique_mash_groups
    )
    
    # Create the static heatmap for AMR counts using ggplot2
    heatmap <- ggplot(melted_data, aes(x = Sample, y = AMR, fill = as.factor(Count))) +
      geom_tile(color = "gray") +
      scale_fill_manual(
        values = c("0" = "white", "1" = "blue", "2" = "red", "3" = "limegreen", "4" = "black"),
        name = "Count"
      ) +
      theme_bw() +
      theme(
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        axis.text.y = element_text(size = 10),
        axis.title.x = element_text(size = 12),
        axis.title.y = element_text(size = 12),
        legend.position = "right",
        legend.text = element_text(size = 14),  # Doubled legend font size
        legend.title = element_text(size = 16),  # Doubled legend title font size
        plot.margin = margin(5, 5, 10, 10)
      ) +
      labs(x = NULL, y = "Resistance Genes")
    
    
    abundance_data <- melted_data %>% 
      group_by(Sample) %>% 
      summarise(Abundance = sum(Count))
    
    abundance_data$Sample <- factor(abundance_data$Sample, levels = levels(melted_data$Sample))
    
    histogram <- ggplot(abundance_data, aes(x = Sample, y = Abundance)) +
      geom_bar(stat = "identity", fill = "turquoise3") +
      theme_bw() +
      theme(
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        axis.text.y = element_text(size = 10),
        axis.title.x = element_blank(),
        axis.title.y = element_text(size = 12),
        plot.margin = margin(10, 10, 10, 10)
      ) +
      labs(y = "Abundance")
    
    
    
    # Add Mash group and Source color bars
    # Add Mash group and Source color bars with controlled font sizes
    mash_group_bar <- ggplot(unique(melted_data[, c("Sample", "mash_group")]), aes(x = Sample, y = 1, fill = mash_group)) +
      geom_tile(height = 0.1) +
      scale_fill_manual(values = mash_group_colors, name = "Mash Group") +
      theme_void() +
      theme(
        legend.position = "bottom",
        legend.title = element_text(size = 14, face = "bold"),   # Adjust legend title size and style
        legend.text = element_text(size = 12)                   # Adjust legend text size
      )
    
    source_bar <- ggplot(unique(melted_data[, c("Sample", "source")]), aes(x = Sample, y = 1, fill = source)) +
      geom_tile(height = 0.1) +
      scale_fill_manual(values = source_colors, name = "Source") +
      theme_void() +
      theme(
        legend.position = "bottom",
        legend.title = element_text(size = 14, face = "bold"),   # Adjust legend title size and style
        legend.text = element_text(size = 12)                   # Adjust legend text size
      )
    
    
    
    # Determine heights based on context (display vs download)
    if (for_download) {
      heatmap_height <- 40
    } else {
      heatmap_height <- 60  # Double the height for display; adjust as needed
    }
    
    # Combine the heatmap and color bars using patchwork
    combined_plot <- (histogram / heatmap / mash_group_bar / source_bar) +
      plot_layout(heights = c(5, heatmap_height, 2, 2), guides = "collect") &  # Adjusted heatmap height
      theme(
        plot.margin = margin(t = 1, b = 1, l = 10, r = 10),
        legend.position = "bottom"
      )
    
    return(combined_plot)
  }
  
  # Render the static heatmap using ggplot2
  output$amr_heatmap <- renderPlot({
    combined_plot <- generate_combined_plot(for_download = FALSE)
    if (is.null(combined_plot)) return(NULL)
    print(combined_plot)
  }, height = function() {
    # Set the height to 1.5 times the default height
    750  # Assuming the default height was 500, 500 * 1.5 = 750
  })
  
  
  # Download handler for the static plot
  output$download_plot <- downloadHandler(
    filename = function() {
      paste("amr_heatmap", Sys.Date(), ".png", sep = "")
    },
    content = function(file) {
      combined_plot <- generate_combined_plot(for_download = TRUE)
      if (is.null(combined_plot)) {
        showNotification("No plot available to download.", type = "error")
        return(NULL)
      }
      
      # Save the combined plot to the specified file with standard height
      ggsave(file, plot = combined_plot, width = 15, height = 10, dpi = 300)  # Standard height for download
    }
  )
}

