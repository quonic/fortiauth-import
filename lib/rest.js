"use strict";

/*
 Root / Allows querying of available resources.
 GET
 */
const REST_ROOT = "/";

/*
 Local User Management /localusers/ Allows the creation, modification and deletion of user accounts.
 GET, POST, PATCH
 */
const REST_LOCALUSERS = REST_ROOT + "localusers/";

/*
 Local Group Management /usergroups/ Allows the creation and deletion of user groups and specify users within that group.
 GET, POST, PUT, DELETE
 */
const REST_USERSGROUPS = REST_ROOT + "usergroups/";

/*
 Local Group Membership /localgroupmemberships/ Represents local user group membership resource (relationship between local user and local user group).
 GET, POST, DELETE
 */
const REST_LOCALGROUPMEMBERSHIPS = REST_ROOT + "localgroupmemberships/";

/*
 User Authentication /auth/ Allows validation of user authentication credentials.
 POST
 */
const REST_AUTH = REST_ROOT + "auth/";

/*
 FortiToken /fortitokens/ Allows provisioning of FortiTokens. SSO Group /ssogroup/ Enables remote configuration of the SSO & Dynamic Policies à SSO à SSO Groups table.
 GET, POST, DELETE
 */
const REST_FORTITOKENS = REST_ROOT + "fortitokens/";

/*
 FortiGate Filter Group /fgtgroupfilter/ Enables remote configuration of the SSO & Dynamic Policies à SSOà FortiGate Group Filtering table.
 GET, PUT
 */
const REST_FGTGROUPFILTER = REST_ROOT + "fgtgroupfilter/";

/*
 SSO Authentication /ssoauth/ Adds/removes a user from the FSSO logged in users table.
 POST
 */
const REST_SSOAUTH = REST_ROOT + "ssoauth/";

const HTTP_OK = 200; // OK The request was successfully completed.
const HTTP_CREATED = 201; // The request successfully created a new resource and the response body does not contain the newly created resource.
const HTTP_ACCEPTED = 202; // The server fulfilled the request and the response body contains the newly updated resource.
const HTTP_NO_CONTENT = 204; // The server fulfilled the request, but does not need to return a response message body.
const HTTP_BAD_REQUEST = 400; // The request could not be processed because it contains missing or invalid information (i.e. the data in the request does not validate).
const HTTP_NOT_AUTHORIZED = 401; // The supplied credential is incorrect.
const HTTP_FORBIDDEN = 403; // Permission is denied to perform an operation.
const HTTP_INTERNAL_SERVER_ERROR = 500; // The server encountered an unexpected condition which prevented it fromfulfilling the request.

module.exports.HTTP_OK = HTTP_OK;
module.exports.HTTP_CREATED = HTTP_CREATED;
module.exports.HTTP_ACCEPTED = HTTP_ACCEPTED;
module.exports.HTTP_NO_CONTENT = HTTP_NO_CONTENT;
module.exports.HTTP_BAD_REQUEST = HTTP_BAD_REQUEST;
module.exports.HTTP_NOT_AUTHORIZED = HTTP_NOT_AUTHORIZED;
module.exports.HTTP_FORBIDDEN = HTTP_FORBIDDEN;
module.exports.HTTP_INTERNAL_SERVER_ERROR = HTTP_INTERNAL_SERVER_ERROR;

var servers, credentials, api_version;

var config_define = {
    "servers": ["", ""],
    "api_version": "",
    "credentials": {
        "username": "",
        "key": ""
    }
};

module.exports.setConfig = function (config) {
    servers = config.servers;
    credentials = config.credentials;
    api_version = config.api_version;
};

module.exports.removeToken = function (user) {

};

var querystring = require('querystring');
var https = require('https');

function performRequest(host, endpoint, method, data, success) {
    var dataString = JSON.stringify(data);
    var headers = {};

    if (method === 'GET') {
        endpoint += '?' + querystring.stringify(data);
    } else {
        headers = {
            'Content-Type': 'application/json',
            'Content-Length': dataString.length
        };
    }
    var options = {
        host: host,
        path: endpoint,
        method: method,
        headers: headers
    };

    var req = https.request(options, function (res) {
        res.setEncoding('utf-8');

        var responseString = '';

        res.on('data', function (data) {
            responseString += data;
        });

        res.on('end', function () {
            console.log(responseString);
            var responseObject = JSON.parse(responseString);
            success(responseObject);
        });
    });

    req.write(dataString);
    req.end();
}

module.exports.getResources = function () {
    let result = null;

    for (let server in servers) {
        if (!servers.hasOwnProperty(server)) {
            continue;
        }
        performRequest(server, "/api/" + api_version + REST_ROOT + "?format=json", 'GET', {
            username: credentials.username,
            password: credentials.key
        }, function (data) {
            console.log('Data: ', data);
            result = result + data;
            // TODO add more checks if we can access all needs parts of the API
        });
    }

    return result;
};

module.exports.getUser = function (user) {
    //TODO get all data for user
    let result = null;

    for (let server in servers) {
        if (!servers.hasOwnProperty(server)) {
            continue;
        }
        performRequest(server, "/api/" + api_version + REST_LOCALUSERS + "?format=json&username=" + user, 'GET', {
            username: credentials.username,
            password: credentials.key
        }, function (data) {
            console.log('Data: ', data);
            result = result + data;
        });
    }

    return result;
};