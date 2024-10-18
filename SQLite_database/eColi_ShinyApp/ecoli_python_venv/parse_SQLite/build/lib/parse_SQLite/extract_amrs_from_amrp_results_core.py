"""
Script Name: extract_amrs_from_amrp_results_core.py
Author: Juan Jovel
Date: 2024-09-05
Description:
    This script connects to an SQLite database, queries data from the 'amrp_results' table where the 'scope' is 'core',
    and generates a pivot table with 'gene_symbol' as rows and 'sample_id' as columns. The resulting pivot table
    is saved to a TSV file ('amrp_results_report-core.tsv').

Dependencies:
    - sqlite3
    - pandas

Instructions:
    1. Ensure you have the necessary Python libraries installed:
        pip install pandas
    2. Place the script in the same directory as the 'Ecoli.db' database or modify the path accordingly.
    3. Run the script:
        python extract_amrs_from_amrp_results-core.py 

Outputs:
    - A pivot table displayed in the console.
    - A TSV file ('amrp_results_report-core.tsv') saved to the current directory.

"""

# Import necessary libraries
import sqlite3
import pandas as pd
import os

db_dir='/Users/juanjovel/OneDrive/jj/UofC/data_analysis/sylviaCheckley/alyssaButters/eColi_genomics/SQLite_database'
database=os.path.join(db_dir, 'Ecoli.db')

table = 'amrp_results'  # Correct table name
keyword = 'core'  # The keyword to search for

# Connect to the SQLite database
conn = sqlite3.connect(database)

# SQL query to select necessary columns where scope is 'core'
query = f"""
SELECT sample_id, gene_symbol
FROM {table}
WHERE scope = ?
"""

# Read data into a pandas DataFrame using the keyword as a parameter to prevent SQL injection
df = pd.read_sql_query(query, conn, params=(keyword,))

# Close the database connection
conn.close()

# Display the first few rows of the dataframe
print("Initial DataFrame:")
print(df.head())

# Create a pivot table with gene_symbol as rows and sample_id as columns
pivot_df = df.pivot_table(index='gene_symbol', columns='sample_id', aggfunc='size', fill_value=0)

# Display the pivot table
print("\nPivot Table:")
print(pivot_df)

# Optionally, save the pivot table to a TSV file
pivot_df.to_csv('amrp_results_report-core.tsv', sep='\t', index=True)

print("\nPivot table saved to 'amrp_results_report-core.tsv'.")
