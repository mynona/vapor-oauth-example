# Simple VaporOAuth example for the Authorization Grant Flow

https://github.com/brokenhandsio/vapor-oauth

(PKCE is not supported.)

# Context

This repository is based on the oauth example by marius-se:

https://github.com/marius-se/vapor-oauth2-example

As there were essential flows missing such as token introspection, I extended this
example. 

Unfortunately, vapor/oauth doesn't compile on linux anymore. Therefore, I used the following fork, where these issues are fixed:

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


# What is included

* Client requests Authorization code
* Server provides login screen (username, password)
* Server side data handling: sessions for user data, db clients, db resource servers
* Server returns Authorization code to client
* Client requests Access/Refresh token in exchange of Authorization code
* Server returns Access token as JWT token
* Server returns Refresh token as UUID value
* Client stores both tokens as cookies on the client (reason: make it available for all microservices)
* Client checks token_info endpoint to access restricted resources
* Client can request a new access_token with the refresh_token
* Client logout will just destroy the cookies in this example


