# Simple VaporOAuth example for the Authorization Grant Flow

https://github.com/brokenhandsio/vapor-oauth


# Context

This repository is based on the oauth example by marius-se:

https://github.com/marius-se/vapor-oauth2-example

As there were essential flows missing such as token introspection, I extended this
example. 

Unfortunately, vapor/oauth doesn't compile on linux anymore. Therefore, I used the following fork, where these issues are fixed and additionally, PKCE is supported.

https://github.com/vamsii777/vapor-oauth.git

# Get started

To see it working start both applications.

The client will run at port 8089 and the server at port 8090.

Start the client with http://localhost:8089

* Access tokens are valid only for 1 minute for testing purposes.
* Refresh tokens have no expiration.

# Learning resources

I recommend the following book as it does not only explain the theory but takes you through the whole flow with the required code:

https://leanpub.com/themodernguidetooauth 

As for the theory part:

https://www.oauth.com


# What is included in this example?

* Client requests Authorization code (with PKCE)
* Server provides login screen (username, password)
* Server side data handling: sessions for user data, db clients, db resource servers, db authorization code
* Server returns Authorization code to client
* Client requests Access/Refresh token in exchange of Authorization code
* Server returns Access token as JWT token
* Server returns Refresh token as UUID value
* Server deletes expired Access tokens
* Server deletes expired Refesh tokens 
* Client stores both tokens as cookies on the client (reason: make it available for all microservices)
* Client checks token_info endpoint to access restricted resources
* Client can request a new access_token with the refresh_token flow
* Client logout will just destroy the cookies in this example

# Endpoints

Open ID Provider (OAuth server)

* oauth/authorize | Authorization flow
* oauth/token | Exchange refresh token for new access token
* oauth/token_info | Token introspection
* oauth/login | Simple sign-in form

Customized routes on the client side

* /client-login | Start authorization flow
* /callback | Retrieve authorization code and request acess_token and refresh_token
* /refresh | Exchange refresh_token for a new access_token
* /introspection | Example for a protected page that calls the oauth/token_info endpoint


