#!/usr/bin/python 

from Bio import Entrez

Entrez.email = "juan@dayhoff.ai"

def get_gca_accession(assembly_id):
    with Entrez.efetch(db="assembly", rettype="docsum", id=assembly_id) as handle:
        record = Entrez.read(handle, validate=False)

        # Check if 'DocumentSummarySet' and 'DocumentSummary' are present and are not empty
        if ('DocumentSummarySet' in record 
                and 'DocumentSummary' in record['DocumentSummarySet']
                and len(record['DocumentSummarySet']['DocumentSummary']) > 0):
            return record['DocumentSummarySet']['DocumentSummary'][0]['AssemblyAccession']
        else:
            return None

def construct_curl_command(accession):
    base_url = "https://api.ncbi.nlm.nih.gov/datasets/v2alpha/genome/accession"
    params = "include_annotation_type=GENOME_FASTA,GENOME_GFF,RNA_FASTA,CDS_FASTA,PROT_FASTA,SEQUENCE_REPORT"
    filename = f"filename={accession}.zip"
    url = f"{base_url}/{accession}/download?{params}&{filename}"
    return f'curl -OJX GET "{url}" -H "Accept: application/zip"'

outdata = open("curl_commands.txt", 'a')
with open('ids.txt', 'r') as rf:
    for line in rf:
        assembly_id = line.strip()
        accession = get_gca_accession(assembly_id)
        if accession:  # check that accession is not None
            curl_command = construct_curl_command(accession)
            outdata.write(f'{assembly_id}\t {curl_command}\n')
outdata.close()
