#!/usr/bin/env python3

# modifyDataStore.py, a python script by Ben Guaraldi

import sys
import json
import requests
import collections

# Customize for you
yourname = ''
if not(yourname):
	print('Please enter your name in the code')
	sys.exit(1)

key = 'Python_' + yourname

# Get parameters from dish.json
config = json.load(open('dish.json', 'r'))
url = config['dhis']['baseurl'] + '/api/dataStore/assignments/organisationUnitLevels.json'

# Get the current JSON from the organisationUnitLevels key of the assignments namespace 
# in the data store
credentials = (config['dhis']['username'], config['dhis']['password'])
req = requests.get(url, auth=credentials)
firstJson = req.json()

# Construct a new JSON from the current JSON, adding a new key and resorting it
firstJson[key] = firstJson['Angola'].copy()
firstJson[key]['name3'] = key
sortedKeys = sorted(firstJson.items())

# Since dicts don't have an order to their indices, 
# we need to create an ordered dict and then 
# save the sorted values to it
secondJson = collections.OrderedDict()
for i in sortedKeys:
	secondJson[i[0]] = i[1]

# Replace the old JSON with the new JSON
print(requests.put(url, data=json.dumps(secondJson), auth=credentials, headers={'content-type': 'application/json'}))

# Report completion and exit with status 0
print('Exiting normally')
exit(0)