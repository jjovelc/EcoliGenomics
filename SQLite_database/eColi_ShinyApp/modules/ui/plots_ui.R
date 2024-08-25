# modules/plots_ui.R

plots_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    # # CSS
    tags$head(
      tags$style(HTML("
    
        h3 {
        font-size: 26px;
        }
        .well {
         color: white;
         background-color: gray100;
        }
                    "))
    ),
    sidebarLayout(
      sidebarPanel(
        selectInput(ns("plotType"), "Select Plot Type:", choices = c("UMAP", "Ridge Plot", "Dot Plot")),
        
        conditionalPanel(
          condition = sprintf("input['%s'] == 'UMAP'", ns("plotType")),
          selectInput(ns("groupBy"), "Group By:", choices = c("seurat_clusters", "cell_type_v2", "gene")),
          conditionalPanel(
            condition = sprintf("input['%s'] == 'gene'", ns("groupBy")),
            selectizeInput(ns("gene"), "Select Gene:", choices = NULL, 
                           options = list(placeholder = "Select or search gene name",
                                          maxOptions = 30000,
                                          searchConjunction = 'and')),
            selectInput(ns("colorPalette"), "Select Color Palette:", choices = palette_names),
            numericInput(ns("startBreak"), "Start from break:", value = 1, min = 1, max = 9, step = 1)
          )
        ),
        
        conditionalPanel(
          condition = sprintf("input['%s'] == 'Ridge Plot'", ns("plotType")),
          selectizeInput(ns("ridgeGenes"), "Select Genes for Ridge Plot:", choices = NULL, multiple = TRUE, 
                         options = list(placeholder = "Select or search gene names",
                                        maxOptions = 30000,
                                        searchConjunction = 'and')),
          selectInput(ns("ridgeGroupBy"), "Group By:", choices = c("seurat_clusters", "cell_type_v2"))
        ),
        
        conditionalPanel(
          condition = sprintf("input['%s'] == 'Dot Plot'", ns("plotType")),
          selectizeInput(ns("dotGenes"), "Select Genes for Dot Plot:", choices = NULL, multiple = TRUE, 
                         options = list(placeholder = "Select or search gene names",
                                        maxOptions = 30000,
                                        searchConjunction = 'and')),
          textAreaInput(ns("geneList"), "Paste Genes for Dot Plot (comma or newline separated):", 
                        placeholder = "Enter genes separated by commas or new lines"),
          selectInput(ns("dotGroupBy"), "Group By:", choices = c("seurat_clusters", "cell_type_v2"))
        ),
        width = 3
      ),
      
      mainPanel(
        downloadButton(ns("downloadPlotPNG"), "Download Plot as PNG"),
        width = 9,
        div(class = "square-plot-container",
            plotOutput(ns("plotOutput"), width = "100%")
        )
      )
    )
  )
}