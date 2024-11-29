# modules/bgviewer.R


bgviewer_server <- function(input, output, session) {
  observeEvent(input$generate_map, {
    print("Generate Map button clicked.")  # Debug
    
    # Ensure files are uploaded
    req(input$genome_file, input$gff_file)
    
    # File paths
    genome_file <- input$genome_file$datapath
    gff_file    <- input$gff_file$datapath
    
    # Read genome from the FASTA file
    genome <- readDNAStringSet(genome_file)
    
    # Get total genome length
    genome_length <- sum(width(genome))
    
    # Extract the basename of the genome file
    print(paste0("Name of genome file: ", input$genome_file$name))
    genome_basename <- tools::file_path_sans_ext(basename(input$genome_file$name))
    
    print(paste("Uploaded genome file:", genome_file))
    print(paste("Uploaded GFF file:", gff_file))
    print(paste("Genome basename:", genome_basename))
    
    # Parse the GFF file
    gff_data <- import(gff_file)  # GRanges object
    
    # Filter for CDS features
    cds_data <- gff_data[gff_data$type == "CDS"]
    
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
    
    # Convert to JSON string
    genes_json <- toJSON(genes, auto_unbox = TRUE)  # Ensure proper JSON string
    
    print("Sending JSON data to the frontend:")  # Debug
    
    # Prepare data to send to the frontend
    message <- list(
      genes = genes_json,
      genomeLength = genome_length,
      filename = genome_basename
    )
    
    # Send JSON to JavaScript
    session$sendCustomMessage("updateGenomeMap", message)
  })
}
