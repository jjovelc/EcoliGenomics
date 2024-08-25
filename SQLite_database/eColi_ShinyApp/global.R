# globals.R
library(shiny)
library(DT)
library(RSQLite)
library(tidyverse)
library(shinydashboard)
library(shinythemes)

options(shiny.maxRequestSize = 5000*1024^2)

# Connect to your SQLite database
con <- dbConnect(RSQLite::SQLite(), "/Users/juanjovel/OneDrive/jj/UofC/data_analysis/sylviaCheckley/alyssaButters/eColi_genomics/SQLite_database/Ecoli.db")

# Get list of tables in the database
tables <- dbListTables(con)