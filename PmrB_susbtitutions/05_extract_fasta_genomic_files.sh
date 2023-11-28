#!/bin/bash

# Define top level directory
TOP_DIR="."

# Iterate over all directories matching *_genome in the top directory
for genome_dir in "${TOP_DIR}"/*_genome; do

    if [ -d "${genome_dir}" ]; then
        # Extract directory name without path
        DIR_NAME=$(basename "${genome_dir}")

        # Construct the new file name based on the directory name
        NEW_FILE_NAME="${DIR_NAME/_genome/.fasta}"

        # Search for the _genomic.fna files larger than 4MB
        find "${genome_dir}" -type f -name "*_genomic.fna" -size +4M -print0 | while IFS= read -r -d $'\0' file; do
            # Copy and rename the file
            cp "${file}" "./${NEW_FILE_NAME}"
        done
    fi
done
