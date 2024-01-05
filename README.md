# Simple VaporOAuth (OIDC) example of the Authorization Grant Flow

https://github.com/brokenhandsio/vapor-oauth

---
# Context

This repository is based on the oauth example by marius-se:

https://github.com/marius-se/vapor-oauth2-example

Unfortunately, vapor/oauth doesn't compile on linux anymore and doesn't support PKCE.

Therefore, I used the following fork which is updated to vapor 4.90.0 and includes OpenID Connect support:

https://github.com/vamsii777/vapor-oauth.git

---
# Get started

To see it working start both applications.

The client will run at port 8089 and the server at port 8090.

Start the client with http://localhost:8089

* Access tokens are valid only for 1 minute for testing purposes.
* Refresh tokens have no expiration.

All detailed outputs can be seen in the XCode console.

---
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
* /oauth/userinfo | Return OAuthUser
* /.well-known/.well-known/jwks.json | Receive a list of the public RSA keys to validate signatures
* /.well-known/openid-configuration | JSON formatted document with the metadata that identifies all the available endpoints
* /oauth/login | Customized route to offer a simple sign-in form
* /oauth/logout | Customized route to destroy server sessions. Client must sent session cookie

Customized routes on the relying party (client) side

* /client-login | Start authorization flow
* /callback | Retrieve authorization code; request acess_token and refresh_token
* /introspection-test | Page that calls the /oauth/token_info to see if the access_token is valid. If not, try to exchange the refresh_token for a new access_token
* /userinfo-test | Calls oauth/userinfo endpoint with Bearer access_token 
* /client-logout | Initiate logout

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
* **Server** deletes expired tokens from the database whenever new tokens are generated
* Client retrieves publicKey via /.well-known/jwks.json
* Client validates JWT signature and payload of each token
* Client stores access_token, refresh_token and id_token as cookies on the client 
* Client checks /token_info endpoint to access restricted resources
* Client requests a new access_token if the access_token cookie has expired or if the access_token is not valid anymore when the protected page is accessed
* Client can call /oauth/userinfo endpoint and shows result in Xcode console. 
* **Server** can add customized properties to the returned OAuthUser payload
* Client initiates logout
* **Server** destroys session upon logout
* Client destroys cookies upon logout


