#!/usr/bin/env node

// modifyDataStore.js, a python script by Ben Guaraldi

var fs = require('fs');
var request = require('request');

// Get parameters from dish.json

var config = JSON.parse(fs.readFileSync('dish.json'));
var api = 'https://'
	+ config['dhis']['username'] + ':'
	+ config['dhis']['password'] + '@'
	+ config['dhis']['baseurl'].replace(/http.*\:\/\//, '')
	+ '/api/';
var url = api + 'dataStore/assignments/organisationUnitLevels.json';

// Customize for you
var yourname = '';
if (yourname == '') {
	console.log('Please enter your name in the code');
	throw new Error();
}

var key = 'Node_' + yourname;

// Get the current JSON from the organisationUnitLevels key of the assignments namespace 
// in the data store
request({url: url}, function (error, response, body) {
	var firstJson = JSON.parse(body);

	// Construct a new JSON from the current JSON, adding a new key and resorting it
	firstJson[key] = JSON.parse(JSON.stringify(firstJson['Angola']));
	firstJson[key]['name3'] = key;
	var secondJson = {};
	Object.keys(firstJson).sort().forEach(function(k) {
		secondJson[k] = firstJson[k];
	});

	// Replace the old JSON with the new JSON
	request({url: url, method: 'PUT', json: secondJson}, function (error, response, body) {
		// Report completion and exit with status 0
		if (body['httpStatusCode'] == 200) {
			console.log('Exiting normally');
		} else {
			console.log(error);
		}
	});
});