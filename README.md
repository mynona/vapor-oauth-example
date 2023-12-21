# VaporOAuth Example Server

This repository is based on the oauth example by marius-se:

https://github.com/marius-se/vapor-oauth2-example

As it didn't compile on linux anymore and there were essential flows missing such as token introspection, I extended this
example.

# Get started

To see it working start both applications.

The client will run at port 8089 and the server at port 8090.

Start the client with http://localhost:8089

Token introspection can be called via Postman.

# What is missing

* At the moment you have to run the flow twice because the middleware doesn't store the session in time when it hits the authorize endpoint. This needs to be fixed on a fundamental layer = to extend OAuthUser to be a fluent model.
* Refresh Token flow not implemented yet

