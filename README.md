# Simple VaporOAuth (OIDC) example for the Authorization Grant Flow

https://github.com/brokenhandsio/vapor-oauth

---
# Context

This repository is based on the oauth example by marius-se:

https://github.com/marius-se/vapor-oauth2-example

As there were essential flows missing such as token introspection, I extended this
example. 

Unfortunately, vapor/oauth doesn't compile on linux anymore and is outdated. 

Therefore, I used the following fork which is updated to vapor 4.89.3 and includes OpenID Connect support:

https://github.com/vamsii777/vapor-oauth.git

---
# Get started

To see it working start both applications.

The client will run at port 8089 and the server at port 8090.

Start the client with http://localhost:8089

* Access tokens are valid only for 1 minute for testing purposes.
* Refresh tokens have no expiration.

All detailed outputs can be seen in the XCode console.

# Learning resources

I recommend the following book as it does not only explain the theory but takes you through the whole flow with the required code:

https://leanpub.com/themodernguidetooauth 

As for the theory part:

https://developer.okta.com/blog/2017/07/25/oidc-primer-part-1

https://www.oauth.com

---
# Endpoints

Open ID Provider (OAuth server)

* /oauth/authorize | Authorization flow
* /oauth/token | Exchange refresh token for new access token
* /oauth/token_info | Token introspection
* /.well-known/.well-known/jwks.json | Receive a list of the public RSA keys to validate signatures
* /.well-known/openid-configuration | JSON formatted document with the metadata that identifies all the available endpoints
* /oauth/login | Customized route to offer a simple sign-in form

Customized routes on the relying party (client) side

* /client-login | Start authorization flow
* /callback | Retrieve authorization code; request acess_token and refresh_token
* /refresh | Exchange refresh_token for a new access_token
* /introspection-test | Page that calls the /oauth/token_info endpoint

---
# What is included in this example?

Server = OpenID Provider

Client = Relying Party

* Client requests Authorization code (with PKCE)
* **Server** provides login screen (username, password)
* **Server** side data handling: sessions for user data, db clients, db resource servers, db authorization code, db users (sqlite)
* **Server** returns Authorization code to client
* Client requests Access/Refresh token in exchange of Authorization code
* **Server** checks if user is entitled for requested scope
* **Server** returns access_token, refresh_token and id_token as JWT tokens
* Client retrieves publicKey via /.well-known/jwks.json
* Client validates JWT signature and payload of each token
* (**Server** deletes expired tokens from the database)
* Client stores access_token, refresh_token and id_token as cookies on the client 
* Client checks /token_info endpoint to access restricted resources
* Client can request a new access_token with the refresh_token flow
* Client logout will just destroy the cookies on the client side in this example

---
# What is out of scope of this example flow?

* /userinfo endpoint on server side
* Proper mapping of OIDC token claims to the JWT
* Request id_token separately from Authorization Grant Flow

