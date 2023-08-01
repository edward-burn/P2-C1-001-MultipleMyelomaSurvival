# Install dependencies -----
#install.packages("renv") # if not already installed, install renv from CRAN
# renv::restore() # this should prompt you to install the various packages required for the study
# renv::activate()

# Load packages ------
library(lubridate)
library(CDMConnector)
library(IncidencePrevalence)
library(here)
library(DBI)
library(dbplyr)
library(dplyr)
library(CohortSurvival)
library(PatientProfiles)
library(ggplot2)

# database metadata and connection details -----
# The name/ acronym for the database
db_name<-"CPRD GOLD"

# Set output folder location -----
# the path to a folder where the results from this analysis will be saved
output_folder<-here("Results", db_name)

# Database connection details -----
db <- dbConnect(RPostgres::Postgres(),
                dbname =  "cdm_gold_202207",
                port = Sys.getenv("DB_PORT") ,
                host = "163.1.65.51",
                user = Sys.getenv("DB_USER"),
                password =  Sys.getenv("DB_PASSWORD"))
cdm <- CDMConnector::cdm_from_con(con = db,
                                  cdm_schema = "public",
                                  write_schema = "results")

# Run the study ------
source(here("RunStudy.R"))
