"use strict";
let fs = require('fs');
var _ = require('lodash');

// Check if package.json and config.json are in our current directory
let packageFile = './package.json';
let configFile = './config.json';

checkIfFile(packageFile, function (err, isFile) {
    if (!isFile) {
        throw new Error("No package.json file!");
    }
});
checkIfFile(configFile, function (err, isFile) {
    if (!isFile) {
        throw new Error("No config.json file!");
    }
});

// Initialize our REST library

// load package.json and config.json
let config = JSON.parse(fs.readFileSync(configFile, 'utf8'));
let FortiAuth = require('fortiauth-rest');
let rest = new FortiAuth(config);
let packageJSON = JSON.parse(fs.readFileSync(packageFile, 'utf8'));

// get version from package.json
let version = packageJSON.version;

// Help info
let help = "Usage: node ./fai.js [.csv] [-h] [-v]" +
    ".csv: csv file location" +
    "   See import.sample.csv" +
    "-v: print version" +
    "-h: print this help message";

let csvFile = null;

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

checkIfFile(csvFile, function (err, isFile) {
    if (!isFile) {
        throw new Error(csvFile + " not found!");
    }
});

// Import the data
let csvData = null;
let Converter = require("csvtojson").Converter;
let converter = new Converter({});
converter.fromFile(csvFile, function (err, result) {
    console.log(result);
    csvData = result;
});

// csvData is our import data
let results = {};

//Begin

//test connection
if (!rest.testConnection()) {
    throw new Error("Test connection failed!");
}

// Validate CSV data for duplicate usernames, tokens and invalid tokens
let dataError = "";
let throwError = false;
for (let data in csvData) {
    if (!csvData.hasOwnProperty(data)) {
        continue;
    }
    // Check if token is valid
    if (data.token.length !== 16 && !_.startsWith(data.token, "FTK")) {
        if (throwError === false) {
            throwError = true;
        }
        dataError = dataError + "Invalid token: " + data.token + "\n";
    }
    for (let innerData in csvData) {
        if (!csvData.hasOwnProperty(innerData)) {
            continue;
        }
        // Look for duplicate tokens
        if (data.token === innerData.token) {
            dataError = dataError + "Duplicate token: " + data.token + "\n";
        }
        // Look for duplicate usernames
        if (data.username === innerData.username) {
            dataError = dataError + "Duplicate username: " + data.username + "\n";
        }
    }
}
if (throwError) {
    throw new Error(dataError);
}


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


function checkIfFile(file, cb) {
    fs.stat(file, function fsStat(err, stats) {
        if (err) {
            if (err.code === 'ENOENT') {
                return cb(null, false);
            } else {
                return cb(err);
            }
        }
        return cb(null, stats.isFile());
    });
}