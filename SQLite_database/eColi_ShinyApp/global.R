# globals.R
library(shiny)
library(DT)
library(DBI)
library(RSQLite)
library(tidyverse)
library(shinydashboard)
library(shinythemes)
library(ggiraph)

options(shiny.maxRequestSize = 5000*1024^2)

# Connect to your SQLite database
con <- dbConnect(RSQLite::SQLite(), "/Users/juanjovel/OneDrive/jj/UofC/git_repos/EcoliGenomics/SQLite_database/scripts/Ecoli.db")

# Get list of tables in the database
tables <- dbListTables(con)