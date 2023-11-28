#!/bin/bash

while IFS=$'\t' read -r id zipfile; do
    mkdir -p "$id"            # Create a directory with the name of the ID
    unzip "$zipfile" -d "$id" # Unzip the zipfile into the created directory
done < zipFiles_and_ids.txt


for DIR in *_genome
do
        if [ -z "$(ls -A $DIR)" ]; then
                rm -rf $DIR
        fi
done


if [ ! -d genome_files ]; then
  mkdir genome_dirs
fi

# Check if the directory is empty
if [ -z "$(ls -A genome_dirs)" ]; then
  mv *genome genome_dirs
else
  echo "The directory is not empty."
fi


