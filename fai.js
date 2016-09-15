"use strict";
var fs = require('fs');
var path = require('path');

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
var configJSON = JSON.parse(fs.readFileSync(configFile, 'utf8'));
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

// Initialize our REST library
var rest = require('./lib/rest.js')();

// Setup our config data
rest.setConfig(JSON.parse(configJSON));

// csvData is our import data

var results = {};

//Begin

//test connection
rest.getResources();

//TODO Find bad data in CSV file

//TODO Find existing users from CSV
for(let user in csvData){
    if (!csvData.hasOwnProperty(user)) {
        continue;
    }

    let u = rest.getUser(user.username);
    if(u.exists){
        if(u.token !== null){
            let result = rest.removeToken(user.username);
            results.set(user.username, result);
        }
    }
}

//TODO remove tokens from existing users

//TODO find users with tokens assigned to users from CSV

//TODO Create users that don't exist and assign tokens

//TODO Assign group(s) to users

//End
