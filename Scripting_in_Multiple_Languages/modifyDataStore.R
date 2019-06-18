#!/usr/bin/env Rscript

# modifyDataStore.R, an R script by Jason Pickering loosely based 
# on a script by Ben Guaraldi (and lightly edited by same)

require(httr)
require(jsonlite)
require(magrittr)
require(assertthat)

# Get parameters from dish.json

config <- fromJSON('/opt/dhis2/dish.json')
url<-paste0(config$dhis$baseurl, '/api/dataStore/assignments/organisationUnitLevels.json')

# Get the current JSON from the organisationUnitLevels key of the assignments namespace in the data store

j <-GET(url, authenticate(config$dhis$username, config$dhis$password)) %>%
	content(., "text") %>%
	fromJSON(.)

# Customize for you

yourname <- ''
if (nchar(yourname) == 0) {
	stop('Please enter your name in the code')
}

# Construct a new JSON from the current JSON, adding a new key and resorting it

key <- paste('Pirate_', yourname, sep='')
j[[key]] <- j$Zimbabwe
j[[key]]$name3 <- key
j <- j[order(names(j))]

# Replace the old JSON with the new JSON

r <- PUT(url, body = toJSON(j, auto_unbox = TRUE), content_type_json())

# Report completion
message('Exiting normally')
