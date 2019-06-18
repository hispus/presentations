#!/usr/bin/env bash

# modifyDataStore.sh, a shell script by Ben Guaraldi

# If you run on OS X, you probably don't have GNU grep.  You'll need it.
# I fixed this so by installing GNU grep to ggrep and changing
# lines 14, 15, and 16 from grep to ggrep.

# Exit immediately upon non-zero exit status
set -e ; set -o pipefail

# Get parameters from dish.json
url=$(grep -Pzo '(?s)"dhis".*?\{.*?"baseurl":.*?".*?"' dish.json | awk -F'"' '/baseurl/ {print $4}')
username=$(grep -Pzo '(?s)"dhis".*?\{.*?"username":.*?".*?"' dish.json | awk -F'"' '/username/ {print $4}')
password=$(grep -Pzo '(?s)"dhis".*?\{.*?"password":.*?".*?"' dish.json | awk -F'"' '/password/ {print $4}')

# Get the current JSON from the organisationUnitLevels key of the assignments namespace in the data store
json=$(curl -X GET -u "${username:?}:${password:?}" "${url:?}/api/dataStore/assignments/organisationUnitLevels.json")

# Customize for you
yourname=''
if [ -z "$yourname" ]
then
	echo 'Please enter your name in the code'
	exit 1
fi

# Construct a new JSON from the current JSON, adding a new key and resorting it
angola=$(echo $json | tr '}' '\n' | head -1)
new=$(echo $json | tr '}' '\n' | grep 'Ghana' | sed -e "s/Ghana/Bash_$yourname/g")
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