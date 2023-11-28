library(Hmisc)

setwd('/Users/juanjovel/jj/data_analysis/sylviaCheckley/alyssaButters/eColi_genomics/substitutions')

#data <- read.table('genotypes_and_mash-groups_clean.txt', header = T, sep = '\t')
n_samples <- as.character(1000)
infile <- paste(n_samples, 'mash-group.txt', sep = '_')

data <- read.table(infile, header = T, sep = '\t')
dev.off()

# Create a contingency table
table <- table(data$mash_group, data$genotype)


#### Calculate percentage table
# Create a contingency table
table_raw <- table(data$mash_group, data$genotype)

# Calculate percentages
table_percentages_raw <- sweep(table_raw, 2, colSums(table_raw), FUN="/") * 100



# Format to one decimal place
table_percentages <- matrix(sprintf("%.1f", table_percentages_raw), 
                            nrow=nrow(table_percentages_raw))



library(RColorBrewer)
library(gplots)

# Display the heatmap
# Create color palette
colors <- colorRampPalette(rev(brewer.pal(3, "RdYlBu")))(255)


# Display the heatmap with a color legend
# The numbers represent the space at the bottom, left, top, and right respectively.
# Replace column names with a combination of original names and 100% label
new_colnames <- paste0(colnames(table), "\n(100%)")
rownames(table_percentages) <- rownames(table)  # Ensure the row names match

heatmap.2(as.matrix(table), 
          main="", 
          xlab="Genotype", 
          ylab="Mash group", 
          scale="none", 
          col=colors, 
          density.info="none",
          Rowv=NA, 
          Colv=NA, 
          dendrogram='none', 
          key=TRUE, 
          keysize=1.5, 
          trace="none",
          cexRow=1,
          cexCol = 1,
          cex.lab=1.5,    # Adjust font size of x and y titles
          font.lab=2,     # Make x and y titles bold
          las=1,          # Change orientation of x-axis labels to horizontal
          
          srtCol=45,      # Tilt column labels by 45 degrees
          sepwidth=c(0.01,0.01),   # Set separator width
          sepcolor="white",        # Set separator color
          cellnote=as.matrix(table_percentages), # Add values to cells
          notecol="black",          # Set color for cell values
          notecex=1,                 # Adjust font size for cell values
          labCol = new_colnames     # Use new column names
)

dev.off()

##### Correlation analysis
# Convert the columns of table_percentages to numeric
table_percentages_numeric <- matrix(as.numeric(table_percentages), 
                                    nrow=nrow(table_percentages))




# Extract the third and fourth columns
col3 <- table_percentages_numeric[, 3]

# Conduct correlation analysis
#cor_result <- cor.test(col2, col3)

# Compute the correlation matrix
cor_matrix <- cor(table_percentages_numeric)

# Format the correlation matrix to one decimal place
cor_matrix_formatted <- matrix(sprintf("%.1f", cor_matrix), 
                               nrow=nrow(cor_matrix))

# Use heatmap.2 to display the correlation matrix
heatmap.2(cor_matrix, 
          main="Correlation Matrix", 
          scale="none", 
          col=colors, 
          density.info="none",
          Rowv=NA, 
          Colv=NA, 
          dendrogram='none', 
          key=TRUE, 
          keysize=1.5, 
          trace="none",
          cexRow=1,
          cexCol = 1,
          cex.lab=1.5,    # Adjust font size of x and y titles
          font.lab=2,     # Make x and y titles bold
          las=1,          # Change orientation of x-axis labels to horizontal
          sepwidth=c(0.01,0.01),   # Set separator width
          sepcolor="white",        # Set separator color
          cellnote=cor_matrix_formatted, # Add values to cells
          notecol="black",         # Set color for cell values
          notecex=1                # Adjust font size for cell values
)

# Transfer row names
rownames(table_percentages) <- rownames(table_raw)

# Transfer column names
colnames(table_percentages) <- colnames(table_raw)

table_percentages  <- cbind(mash_group=rownames(table_percentages), table_percentages)


table_file <- paste(n_samples, 'percentage_table.txt', sep = '_')
write.table(table_percentages, table_file, sep = '\t',
            quote = F, row.names = F)

