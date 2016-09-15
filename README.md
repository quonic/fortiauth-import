# FortiAuth-Import

Automate the import of users and tokens. Preferably via CSV importing 

# The planed logic flow

* Done: Import from CSV file
* Not Done: Check if token is already in the Available state on other servers
* Not Done: Check for existing tokens and remove the account associated to the token
* Not Done: Add token to server(s)
* Not Done: Check for existing account and remove the token associated with the account
* Not Done: Create user account
* Not Done: Assign Group to user account
* Not Done: Create report of actions taken and actions that have failed
* Not Done: Test that it all works

# References

API reference: [Fortinet Authenticator REST API Documentation](http://docs.fortinet.com/uploaded/files/2596/FortiAuthenticator%204.0%20REST%20API%20Solution%20Guide.pdf)