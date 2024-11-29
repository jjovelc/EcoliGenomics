# modules/bgviewer.R

bgviewer_server <- function(input, output, session) {
  observeEvent(input$generate_map, {
    
    print("Generate Map button clicked.") 
  
    print("File upload triggered")  # Debug
    req(input$genome_file, input$gff_file)  # Ensure both files are uploaded
    
    # File paths
    genome_file <- input$genome_file$datapath
    gff_file    <- input$gff_file$datapath
    
    print(paste("Uploaded genome file:", genome_file))  # Debug
    print(paste("Uploaded GFF file:", gff_file))  # Debug
    
    # Parse the GFF file
    gff_data <- import(gff_file)  # GRanges object
    
    # Filter for CDS features
    cds_data <- gff_data[gff_data$type == "CDS"]
    print(paste("Number of CDS features:", length(cds_data)))  # Debug
    
    # Extract relevant information
    genes <- data.frame(
      contig = as.character(seqnames(cds_data)),
      start = start(cds_data),
      end = end(cds_data),
      strand = as.character(strand(cds_data)),
      attributes = mcols(cds_data)$ID,  # Use "ID" or other relevant metadata column
      product = mcols(cds_data)$product # Use "product" if available
    )
    
    print("Extracted gene data:")  # Debug
    print(head(genes))
    
    # Convert to JSON and send to frontend
    genes_json <- toJSON(genes)
    print("Sending JSON data to the frontend:")  # Debug
    session$sendCustomMessage("updateGenomeMap", genes_json)
  })
}