# VaporOAuth example: Authorization Grant Flow

This repository is based on the oauth example by marius-se:

https://github.com/marius-se/vapor-oauth2-example

As there were essential flows missing such as token introspection, I extended this
example. 

Unfortunately vapor/oauth doesn't compile on linux anymore. Therefore, I used the following fork, where these issues are fixed:

https://github.com/vamsii777/vapor-oauth.git

# Get started

To see it working start both applications.

The client will run at port 8089 and the server at port 8090.

Start the client with http://localhost:8089

# What is included

* Client requests Authorization code
* Server provides login screen (username, password)
* Server user management
* Server returns Authorization code to client
* Client requests Access/Refresh token in exchange of Authorization code
* Server returns Access token as JWT token
* Server returns Refresh token as UUID
* Client stores both tokens as cookies on the client (reason: make it available for all microservices)
* Client checks token_info endpoint to access restricted resources


# What is missing

* At the moment you have to run the flow twice because the middleware doesn't store the session in time when it hits the authorize endpoint. This needs to be fixed on a fundamental layer = to extend OAuthUser to be a fluent model.
* Refresh Token flow not implemented yet

