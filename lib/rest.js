"use strict";

/**
 * @requires Module:node-rest-client
 */
var Client = require('node-rest-client').Client;

/**
 * Root / Allows querying of available resources.
 * GET
 * @type {string}
 */
const REST_ROOT = "/";

/**
 * Local User Management /localusers/ Allows the creation, modification and deletion of user accounts.
 * GET, POST, PATCH
 * @type {string}
 */
const REST_LOCALUSERS = REST_ROOT + "localusers/";

/**
 * Local Group Management /usergroups/ Allows the creation and deletion of user groups and specify users within that group.
 * GET, POST, PUT, DELETE
 * @type {string}
 */
const REST_USERSGROUPS = REST_ROOT + "usergroups/";

/**
 * Local Group Membership /localgroupmemberships/ Represents local user group membership resource (relationship between local user and local user group).
 * GET, POST, DELETE
 * @type {string}
 */
const REST_LOCALGROUPMEMBERSHIPS = REST_ROOT + "localgroupmemberships/";

/**
 * User Authentication /auth/ Allows validation of user authentication credentials.
 * POST
 * @type {string}
 */
const REST_AUTH = REST_ROOT + "auth/";

/**
 * FortiToken /fortitokens/ Allows provisioning of FortiTokens. SSO Group /ssogroup/ Enables remote configuration of the SSO & Dynamic Policies à SSO à SSO Groups table.
 * GET, POST, DELETE
 * @type {string}
 */
const REST_FORTITOKENS = REST_ROOT + "fortitokens/";

/**
 * FortiGate Filter Group /fgtgroupfilter/ Enables remote configuration of the SSO & Dynamic Policies à SSOà FortiGate Group Filtering table.
 * GET, PUT
 * @type {string}
 */
const REST_FGTGROUPFILTER = REST_ROOT + "fgtgroupfilter/";

/**
 * SSO Authentication /ssoauth/ Adds/removes a user from the FSSO logged in users table.
 * POST
 * @type {string}
 */
const REST_SSOAUTH = REST_ROOT + "ssoauth/";

const POST = 'POST';
const GET = 'GET';
const PATCH = 'PATCH';

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

class rest {

    /**
     * Setup what servers we will be talking to with what api version and credentials
     * @param config
     * @param {string} config.servers
     * @param {string} config.credentials
     * @param {string} config.credentials.username
     * @param {string} config.credentials.key
     * @param {string} config.api_version
     */
    static set config(config) {
        this.servers = config.servers;
        this.credentials = config.credentials;
        this.api_version = config.api_version;
    }

    /**
     * set servers to be used to talk to
     * @param serverList - List of servers
     */
    static set servers(serverList) {
        servers = serverList;
    }

    /**
     * get the servers that we are going to talk to
     * @returns {*}
     */
    static get servers() {
        return servers;
    }

    /**
     * set the credential to access the servers
     * @param {string} credential
     * @param {string} credential.username
     * @param {string} credential.key
     */
    static set credentials(credential) {
        credentials = credential;
    }

    /**
     * get the credential that we use to access the servers
     * @returns {*}
     */
    static get credentials() {
        return credentials;
    }

    /**
     * set the api version that the server uses
     * @param apiVersion
     */
    static set api_version(apiVersion) {
        api_version = apiVersion;
    }

    /**
     * get the api version that the server uses
     * @returns {*}
     */
    static get api_version() {
        return api_version;
    }

    /**
     * Perform a REST call
     * @param host - IP address or DNS name of the server
     * @param endpoint - the endpoint to get/post/etc to
     * @param method - What method we should be using, POST/GET/PATCH supported at this time
     * @param data - The data to pass on to the server
     * @param {Function} success - the function called to return our data
     * @param raw - do we want the raw data
     * @callbackparam {Object} Data returned as an Object
     */
    performRequest(host, endpoint, method, data, success, raw = false) {

        var options_auth = {
            user: this.credentials.username,
            password: this.credentials.key
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
                    if(raw){
                        success(data);
                    }else{
                        success(response);
                    }
                }
            });
        } else if (method === "POST") {
            client.post("http://" + host + endpoint, args, function (data, response) {
                if (typeof callback === "function") {
                    if(raw){
                        success(data);
                    }else{
                        success(response);
                    }
                }
            });
        } else if (method === "PATCH") {
            client.patch("http://" + host + endpoint, args, function (data, response) {
                if (typeof callback === "function") {
                    if(raw){
                        success(data);
                    }else{
                        success(response);
                    }
                }
            });
        }else{
            throw new Error("Incorrect method used: Use GET, POST, or PATCH");
        }
    }

    /**
     *
     * @returns {*}
     */
    static resources() {
        let result = null;

        for (let server in this.servers) {
            if (!this.servers.hasOwnProperty(server)) {
                continue;
            }
            this.performRequest(server, "/api/" + this.api_version + REST_ROOT, GET, {},
                function (data) {
                    console.log('Data: ', data);
                    result = result + data;
                    // TODO add more checks if we can access all needs parts of the API
                });
        }
        return result;
    }

    /**
     * Get the JSON data of the user
     * @param {string|number} user - Username or the number of the user
     * @returns {*} - Returns Object with the requested user's data
     */
    static user(user) {
        //TODO get all data for user
        let result = null;

        for (let server in this.servers) {
            if (!this.servers.hasOwnProperty(server)) {
                continue;
            }
            // username__exact
            let endpoint = "/api/" + this.api_version + REST_LOCALUSERS + "?format=json&username__exact=" + user;
            if (Math.isInteger(user)) {
                endpoint = "/api/" + this.api_version + REST_LOCALUSERS + user + "/" + "?format=json";
            }
            this.performRequest(server, endpoint, GET, {},
                function (data) {
                    console.log('Data: ', data);
                    result = result + data;
                });
        }
        return result;
    }

    /**
     *
     * @param groupName - The group name to get a list of users
     * @returns {*} Returns Object with the requested list of users
     */
    static group(groupName) {
        //TODO get all data for user
        let result = null;

        for (let server in this.servers) {
            if (!this.servers.hasOwnProperty(server)) {
                continue;
            }

            // username__exact
            this.performRequest(server, "/api/" + this.api_version + REST_USERSGROUPS + "?format=json&name=" + groupName, GET, {},
                function (data) {
                    // TODO Test that this can be combined.
                    console.log('Data: ', data);
                    result = result + data;
                });

            return result;
        }
    }

    /**
     * Removed the token currently assigned to the user
     * @param {Object} user - User object
     * @param {string} user.username - username as a string
     * @param {string} user.token - The token's serial number
     * @returns {Object} - Returns data as javascript object
     */
    static changeToken(user) {
        let result = null;

        for (let server in this.servers) {
            if (!this.servers.hasOwnProperty(server)) {
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
            this.performRequest(server, "/api/" + this.api_version + REST_LOCALUSERS + "?format=json&username=" + user.username + "&token_code" + user.token, PATCH, {},
                function (data) {
                    console.log('Data: ', data);
                    result = result + data;
                });
        }
        return result;
    }

    /**
     * Returns true if we have access
     * @returns {boolean}
     */
    static testConnection() {
        // This is something that we can compare with what should be returned
        let root = {
            "auth": {
                "list_endpoint": "/api/" + this.api_version + "/auth/",
                "schema": "/api/" + this.api_version + "/auth/schema/"
            },
            "fgtgroupfilter": {
                "list_endpoint": "/api/" + this.api_version + "/fgtgroupfilter/",
                "schema": "/api/" + this.api_version + "/fgtgroupfilter/schema/"
            },
            "fortitokens": {
                "list_endpoint": "/api/" + this.api_version + "/fortitokens/",
                "schema": "/api/" + this.api_version + "/fortitokens/schema/"
            },
            "localusers": {
                "list_endpoint": "/api/" + this.api_version + "/localusers/",
                "schema": "/api/" + this.api_version + "/localusers/schema/"
            },
            "ssoauth": {
                "list_endpoint": "/api/" + this.api_version + "/ssoauth/",
                "schema": "/api/" + this.api_version + "/ssoauth/schema/"
            },
            "ssogroup": {
                "list_endpoint": "/api/" + this.api_version + "/ssogroup/",
                "schema": "/api/" + this.api_version + "/ssogroup/schema/"
            },
            "usergroups": {
                "list_endpoint": "/api/" + this.api_version + "/usergroups/",
                "schema": "/api/" + this.api_version + "/usergroups/schema/"
            }
        };
        let data = this.resources();
        if (data && data.auth && data.auth.list_endpoint === root.auth.list_endpoint &&
            data.localusers && data.localusers.list_endpoint && data.localusers.list_endpoint === root.localusers.list_endpoint &&
            data.fortitokens && data.fortitokens.list_endpoint && data.fortitokens.list_endpoint === root.fortitokens.list_endpoint &&
            data.usergroups && data.usergroups.list_endpoint && data.usergroups.list_endpoint === root.usergroups.list_endpoint) {
            return true;
        }
        return false;
    }
}
module.export = rest();