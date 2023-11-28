# PmrB substitutions associatted with collistin resistance
---
Collistin resistance in E. coli is of great importance because such antibiotic is used to treat multidrug resistant infections. Amino acids substitutions in PmrB have been implicated in colistin resistance in E. coli.

We analyzed 288 bacterial genomes sequenced in-house as well as a series of publicly available genomes. Our goal was to profile the substitutions PmrB Y358N and E123D and contextualize them in E.coli phylogeny and determine their association with reported resistance to collistin.

The bioinformatics pipeline used is described hereafter:

1. Initially, we used the 00_Rentrez.R script to download 15,000 E. coli genome IDs.

```bash
R CMD BATCH 00_Rentrez.R
```

This script will generate a text file called 'ecoli_assembly_ids.txt' containing one genome id per line. This file will serve as input fot the script 01_entrez.py

```bash
python 01_entrez.py ecoli_assembly_ids.txt
```
2. For each accession number, the previous script will generate a line like this one:

14557891         curl -OJX GET "https://api.ncbi.nlm.nih.gov/datasets/v2alpha/genome/accession/GCA_026423435.1/download?include_annotation_type=GENOME_FASTA,GENOME_GFF,RNA_FASTA,CDS_FASTA,PROT_FASTA,SEQUENCE_REPORT&filename=GCA_026423435.1.zip" -H "Accept: application/zip"

Each line has two columns, the first one is the accession number and the second column contains the explicit curl command needed to download the data.

3. The script 02_curl.sh will execute commands in the 2nd column of 'curl_commands.txt' and effectively download the data.

A zipped file should be downloaded for each accession. For example, the following zipped file will result from the command above: GCA_026423435.1.zip.

When we decompress such a file, it will produce a folder named 'ncbi_dataset' with the following content:

```bash
ls ncbi_dataset/data/
```
```
assembly_data_report.jsonl
dataset_catalog.json
GCA_026423435.1
```
Now we can inspect the directory named with the accession number:

```bash
ls ncbi_dataset/data/GCA_026423435.1
```

You will have the following content:

```
cds_from_genomic.fna
genomic.gff
sequence_report.jsonl
GCA_026423435.1_PDT001501795.1_genomic.fna
protein.faa
```
<br>
Our file of interest is the one with the suffix '_genomic.fna'; this is the one holding the sequences.
<br><br>
So, to be able to extract the content of each zip file to a directory named accoding to accession numbers, a list like this is generated:

```
14557891_genome	GCA_026423435.1.zip
3389111_genome	GCF_006231045.1.zip
15566111_genome	GCA_028031265.1.zip
1080981_genome	GCF_002110545.1.zip
7898601_genome	GCA_012926405.2.zip
12376191_genome	GCA_022686715.1.zip
304981_genome	GCF_000941895.1.zip
5475331_genome	GCA_009901485.1.zip
12206971_genome	GCA_022330445.1.zip
6503681_genome	GCA_011839935.1.zip
```
This is done this way:
<br>

```bash
bash 03_extract_zip_file_name.sh
```

<br>
The previous command will automatically call file 'curl_commands.txt' and will parse it to extract the accession number and the zip directory.

1. Now will extract each zip file to a directory named according to the accession number. For example, for pair: 14557891_genome	GCA_026423435.1.zip, the zip file 'GCA_026423435.1.zip' will be extracted to a directory called 14557891_genome (and not more ncbi_dataset).<br>
   
2. Extraction of zip files is done witht the following command:
   
```bash
bash 04_unzip_files.sh
```

6. The previous script will generate one directory per accession with the suffix _genome; all those direcrories will be moved to a single directory called 'genome_dirs'

```bash
mkdir genome_dirs
mv *_genome genome_dirs
cd genome_dirs
```

7. Extract from each directory the file containing the genomic sequences (as described in 3).

```bash
bash 05_extract_fasta_genomic_files.sh
```
Since the E. coli genomes are between 4.5 and 6.5 Mb, only files that are 4 Mbytes or larger will be considered. The smaller ones will be ignored. 

8. Let's move the extracted assembled genomes to another directory called selected_fasta_files where they will be further processed.

```bash
mkdir selected_fasta_files
mv *fasta selected_fasta_files
cd selected_fasta_files
```

9. Run amrfinder on all fasta files (if the process wants to be speeded out, divide the files into batches).

Armfinder by default, among many other things, look for substitutions in the PmrB gene, particularly (Y358N and D123E) and use them as markers for collistin resistance. So, in this case, it is used to screen for such substitutions in the PmrB gene.

```bash
PROCS=12
for FILE in *.fasta; 
do 
amrfinder -O Escherichia -n $FILE --threads $PROCS > ${FILE/.fasta/_amrfinder}; 
done
```
<br>

10. Run clermont software to determine Mash group and Phylogroup to which the genome belongs to.

```bash
for FILE in *.fasta; 
do 
clermonTyping.sh --fasta $FILE --name ${FILE/.fasta/_clermont}; 
done
```

11. Finally, we parse the results produced by amrfinder and clermont:
    
* For amrfinder:
```bash
bash 06_parse_amrfinder.sh
``` 

* For clermont:
```bash
for DIR in *clermont; 
do 
cp ${DIR}/*html .; 
done

bash 07_parse_Mash-group.sh
```

There are a couple edits to do to create a working list for plotting and other analyses, but that can be done in several ways and is very simple to do with standard bash command lines.

We called that file: Mash_groups_and_substitutions.tsv and it should have the following format:
```
genome  mash_group  genotype
10002161: B1  Y358N
10003971: B1  Y358N
10004151: B1  Y358N
10004281: B1  Y358N
10004571: A WT
10004581: B1  Y358N
10006361: B1  Y358N
10009531: D WT
10009571: A WT
```
<br>

To generate random samples with different number of genomes from that file do:

```bash
    python extract_random_samples.py Mash_groups_and_substitutions.tsv
```

Such sub-samples were used to generate saturation line plots.

To generate both, the saturation line plots and the heatmaps presented in the associated paper, we used script: phylogroups_and_substitutions.R.