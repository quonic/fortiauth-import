"use strict";
var fs = require('fs');
var path = require('path');
// Initialize our REST library
var REST = require('fortiauth-rest')();
var rest = new REST();

// Check if package.json and config.json are in our current directory
var packageFile = './package.json';
var configFile = './config.json';
fs.stat(path, (err, stats) => {
    if (!stats.isFile(packageFile)) {
        throw new Error("No package.json file!");
    }
    if (!stats.isFile(configFile)) {
        throw new Error("No config.json file!");
    }
});

// load package.json and config.json
rest.config = JSON.parse(fs.readFileSync(configFile, 'utf8'));
var packageJSON = JSON.parse(fs.readFileSync(packageFile, 'utf8'));

// get version from package.json
var version = packageJSON.version;

// Help info
var help = "Usage: node ./fai.js [.csv] [-h] [-v]" +
    ".csv: csv file location" +
    "   See import.sample.csv" +
    "-v: print version" +
    "-h: print this help message";

var csvFile = null;

// CLI commands
process.argv.forEach(function (val, index, array) {
    console.log(index + ': ' + val);
    if (val.includes(".csv")) {
        csvFile = val;
    }
    if (val === "-h" || val === "--h" || val === "--help" || val === "-help") {
        console.log(help);
        process.exit();
    }
    if (val === "-v") {
        console.log("Version: " + version);
    }
});

// If a csv file wasn't specified then throw an error
if (csvFile === null) {
    console.log(help);
    throw new Error("No CSV file specified!");
}

fs.stat(path, (err, stats) => {
    if (!stats.isFile(csvFile)) {
        console.log(help);
        throw new Error(csvFile + " not found!");
    }
});

// Import the data
var csvData = null;
var Converter = require("csvtojson").Converter;
var converter = new Converter({});
converter.fromFile(csvFile, function (err, result) {
    console.log(result);
    csvData = result;
});

// csvData is our import data
var results = {};

//Begin

//test connection
if (!rest.testConnection()) {
    throw new Error("Test connection failed!");
}

/*
 TODO Find bad data in CSV file
 As in malformed token serial numbers, missing username, etc.
 The more check we do before making REST calls,
 the less error handling we have to do for the REST calls.
 */

//TODO find tokens that are not in the available state from the CSV, and remove them from their existing user
//  Disable or assign a temp token? Disable seems to be the most reliable, but should this be optional?

//TODO Add token to server(s)
// Prefer the first server. Make this optional somehow?

//TODO Find existing users from CSV
for (let data in csvData) {
    if (!csvData.hasOwnProperty(data)) {
        continue;
    }

    let u = rest.user(data.username);
    if (u.exists) {
        if (u.token !== "") {
            //TODO remove tokens from existing users
            let result = rest.changeToken({username: data.username, token: ""});
            results.set(data.username, result);
        }
        let result = rest.changeToken({username: data.username, token: data.token});
        results.set(data.username, result);
    }
}

//TODO Create users that don't exist and assign tokens

//TODO Assign group(s) to users
for (let data in csvData) {
    if (!csvData.hasOwnProperty(data)) {
        continue;
    }

    if (rest.group(data.group).length) {
    }
}


//TODO Print/Save report?
// Have option to export to CSV/HTML/XML?

//End
