#!/usr/bin/env Rscript

# modifyDataStore.R, an R script by Jason Pickering loosely based 
# on a script by Ben Guaraldi (and lightly edited by same)

require(httr)
require(jsonlite)
require(magrittr)
require(assertthat)

# Customize for you
yourname <- ''
if (nchar(yourname) == 0) {
	stop('Please enter your name in the code')
}

# Get parameters from dish.json
config <- fromJSON('dish.json')
url<-paste0(config$dhis$baseurl, '/api/dataStore/assignments/organisationUnitLevels.json')

# Get the current JSON from the organisationUnitLevels key of the assignments namespace in the data store
json <- GET(url, authenticate(config$dhis$username, config$dhis$password)) %>%
	content(., "text") %>%
	fromJSON(.)

# Construct a new JSON from the current JSON, adding a new key and resorting it
key <- paste('Pirate_', yourname, sep='')
json[[key]] <- json$Zimbabwe
json[[key]]$name3 <- key
json <- json[order(names(json))]

# Replace the old JSON with the new JSON
r <- PUT(url, body = toJSON(json, auto_unbox = TRUE), content_type_json())

# Report completion
message('Exiting normally')
