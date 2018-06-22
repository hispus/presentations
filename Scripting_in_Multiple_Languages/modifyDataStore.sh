#!/usr/bin/env bash

# modifyDataStore.sh, a shell script by Ben Guaraldi

# If run on OS X, you must install GNU grep to ggrep.
# If run on something other than OS X, it will probably work if you change lines
# 14, 15, and 16 from ggrep to grep.

# Exit immediately upon non-zero exit status
set -e ; set -o pipefail

# Get parameters from dish.json

url=$(ggrep -Pzo '(?s)"dhis".*?\{.*?"baseurl":.*?".*?"' /opt/dhis2/dish.json | awk -F'"' '/baseurl/ {print $4}')
username=$(ggrep -Pzo '(?s)"dhis".*?\{.*?"username":.*?".*?"' /opt/dhis2/dish.json | awk -F'"' '/username/ {print $4}')
password=$(ggrep -Pzo '(?s)"dhis".*?\{.*?"password":.*?".*?"' /opt/dhis2/dish.json | awk -F'"' '/password/ {print $4}')

# Get the current JSON from the organisationUnitLevels key of the assignments namespace in the data store

json=$(curl -X GET -u "${username:?}:${password:?}" "${url:?}/api/dataStore/assignments/organisationUnitLevels.json")

# Construct a new JSON from the current JSON, adding a new key and resorting it

angola=$(echo $json | tr '}' '\n' | head -1)
new=$(echo $json | tr '}' '\n' | grep 'Ghana' | sed -e 's/Ghana/Bash/g')
sorted=$(printf "$new\n$json" | tr '}' '\n' | sort | grep -v 'Angola')
printf "$angola$sorted}}" | tr '\n' '}' | tee /tmp/final.json | wc

# Replace the old JSON with the new JSON

curl -X PUT -d @/tmp/final.json -H "Content-Type:application/json" -u "${username:?}:${password:?}" "${url:?}/api/dataStore/assignments/organisationUnitLevels"

# Remove the temporary file

rm /tmp/final.json

# Report completion and exit with status 0

echo '.'
echo 'Exiting normally'

exit 0