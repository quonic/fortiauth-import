# FortiAuth-Import

Automate the import of users and tokens. Preferably via CSV importing 

# The planed logic flow

* Import from CSV file
* Check if token is already in the Available state on other servers
* Check for existing tokens and remove the account associated to the token
* Add token to server
* Check for existing account and remove the token associated with the account
* Create user account
* Assign Group to user account
* Create report of actions taken and actions that have failed

# References

API reference: [Fortinet Authenticator REST API Documentation](http://docs.fortinet.com/uploaded/files/2596/FortiAuthenticator%204.0%20REST%20API%20Solution%20Guide.pdf)