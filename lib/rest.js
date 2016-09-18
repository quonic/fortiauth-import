"use strict";

var Client = require('node-rest-client').Client;

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

/**
 * Removed the token currently assigned to the user
 * @param user - user as username
 * @returns {*}
 */
module.exports.removeToken = function (user) {
    let result = null;
    let jsonData = {
        "username": user.username,
        "token_code": user.token
    };
    for (let server in servers) {
        if (!servers.hasOwnProperty(server)) {
            continue;
        }
        /*
         let endpoint = "/api/" + api_version + REST_LOCALUSERS + "?format=json&username=" + user.username + "&token_code=" + user.token;
         if (Math.isInteger(user)){
         endpoint = "/api/" + api_version + REST_LOCALUSERS + user + "/" + "?format=json" + "&token_code=" + user.token;
         }
         performRequest(server, endpoint, 'PATCH', {
         */
        // TODO get this working
        performRequest(server, "/api/" + api_version + REST_LOCALUSERS + "?format=json&username=" + user.username + "&token_code" + user.token, 'PATCH', {},
            function (data) {
                console.log('Data: ', data);
                result = result + data;
            });
    }

    return result;
};

/**
 * Perform a REST call
 * @param host - IP address or DNS name of the server
 * @param endpoint - the endpoint to get/post/etc to
 * @param method - What method we should be using, POST/GET/PATCH supported at this time
 * @param data - The data to pass on to the server
 * @param {Function} success - the function called to return our data
 * @callbackparam {Object} Data returned as an Object
 */
function performRequest(host, endpoint, method, data, success) {

    var options_auth = {
        user: credentials.username,
        password: credentials.key
    };
    var client = new Client(options_auth);
    var args = {
        data: data,
        headers: {
            'Accept': 'application/json',
            "Content-Type": "application/json"
        }
    };
    if (method === "GET") {
        client.get("http://" + host + endpoint, args, function (data, response) {
            if (typeof callback === "function") {
                success(response);
            }
        });
    } else if (method === "POST") {
        client.post("http://" + host + endpoint, args, function (data, response) {
            if (typeof callback === "function") {
                success(response);
            }
        });
    } else if (method === "PATCH") {
        client.patch("http://" + host + endpoint, args, function (data, response) {
            if (typeof callback === "function") {
                success(response);
            }
        });
    }


}

module.exports.getResources = function () {
    let result = null;

    for (let server in servers) {
        if (!servers.hasOwnProperty(server)) {
            continue;
        }
        performRequest(server, "/api/" + api_version + REST_ROOT, 'GET', {},
            function (data) {
                console.log('Data: ', data);
                result = result + data;
                // TODO add more checks if we can access all needs parts of the API
            });
    }

    return result;
};

/**
 * Get the JSON data of the user
 * @param {string|number} user - Username or the number of the user
 * @returns {*} - Returns Object with the requested user's data
 */
module.exports.getUser = function (user) {
    //TODO get all data for user
    let result = null;

    for (let server in servers) {
        if (!servers.hasOwnProperty(server)) {
            continue;
        }
        // username__exact
        let endpoint = "/api/" + api_version + REST_LOCALUSERS + "?format=json&username__exact=" + user;
        if (Math.isInteger(user)) {
            endpoint = "/api/" + api_version + REST_LOCALUSERS + user + "/" + "?format=json";
        }
        performRequest(server, endpoint, 'GET', {},
            function (data) {
                console.log('Data: ', data);
                result = result + data;
            });
    }

    return result;
};

/**
 *
 * @param group - The group name to get a list of users
 * @returns {*} Returns Object with the requested list of users
 */
module.exports.getGroupMembers = function (group) {
    //TODO get all data for user
    let result = null;

    for (let server in servers) {
        if (!servers.hasOwnProperty(server)) {
            continue;
        }
        // username__exact
        performRequest(server, "/api/" + api_version + REST_USERSGROUPS + "?format=json&name=" + group, 'GET', {},
            function (data) {
                // TODO Test that this can be combined.
                console.log('Data: ', data);
                result = result + data;
            });
    }

    return result;
};