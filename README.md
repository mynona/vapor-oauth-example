# Simple VaporOAuth (OIDC) example of the Authorization Grant Flow

https://github.com/brokenhandsio/vapor-oauth

---
# Context

This repository is based on the oauth example by marius-se:

https://github.com/marius-se/vapor-oauth2-example

Branch that supports OpenID Connect:

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

# Usage: Authorization Grant Flow

(Detailed code see example.)

## OpenID Provider:

Add the library to Package.swift:

```
.package(url: "https://github.com/vamsii777/vapor-oauth.git", branch: "feature/jwk")
```

```
// Be aware: this is a work-in-progress branch!!!
.product(name: "OAuth", package: "vapor-oauth")
```

---

Add the OpenID provider to your configure.swift file with the necessary OAuth implementations:

```
import VaporOAuth

public func configure(_ app: Application) throws { 

// ...

let keyManagementService = MyKeyManagementService(app: app)

   app.lifecycle.use(
      OAuth2(
         codeManager: MyAuthorizationCodeManger(app: app),
         tokenManager: MyTokenManager(app: app),
         clientRetriever: MyClientRetriever(app: app),
         authorizeHandler: MyAuthorizationHandler(),
         userManager: MyUserManager(app: app),
         validScopes: nil, //["admin,openid"], value required if no clients defined
         resourceServerRetriever: MyResourceServerRetriever(app: app),
         oAuthHelper: .remote(
            tokenIntrospectionEndpoint: "",
            client: app.client,
            resourceServerUsername: "",
            resourceServerPassword: ""
         ),
         jwtSignerService: MyJWTSignerService(keyManagementService: keyManagementService),
         discoveryDocument: MyDiscoveryDocument(),
         keyManagementService: keyManagementService
      )
   )

// ...

}
```

### AuthorizeHandler:

Manages the Authorization Grant flow:

* handleAuthorizationRequest: in the example this flow is connected to the user login flow. 

### CodeManager:

Responsible for generating and managing Authorization Codes:

* generateCode: generate and persist the authorization `OAuthCode`. 
* retrieveCode: return `OAuthCode`
* codeUsed: delete used `OAuthCode`. Each code can only be used once.

### TokenManager:

Responsible for generating and managing `AccessToken`, `RefreshToken` and `IDToken` tokens as JWT or String.

* generateAccessToken: generate and persist `AccessToken`. In the example the scope of newly requested `AccessTokens` is matched against user entitlements.
* generateRefreshToken: generate and persist `RefreshToken`.
* generateIDToken: generate and persist `IDToken`.
* getAccessToken: Retrieve `AccessToken`. In case of JWT validate token signature. In the example expired tokens are deleted as part of this call.
* getRefreshToken: Retrieve `RefreshToken`. In case of JWT validate token signature. In the example expired tokens are deleted as part of this call.
* updateRefreshToken: Update the scope of a `RefreshToken`.
* generateAccessRefreshTokens and generateTokens: helper functions to generate and return multiple tokens at once.

### ClientRetriever:

Responsible for retrieving clients.

* getClient: return client as `OAuthClient`.

### ResourceServerRetriever:

Responsible for retrieving resource server credentials.

* getServer: returns `OAuthResourceServer` username and password. Used for Basic authentication to exchange the authorization code with tokens.

### UserManager:

Responsible for retrieving `OAuthUser`.

* getUser: retrieve `OAuthUser`. Used to return user details for the introspection endpoint, IDToken…

### JWTSignerService:

Wrapper for the `KeyManagementService`.

### KeyManagementService:

Responsible for generating, persisting and retrieving public and private RSA keys. The public key is also accessible via:

```
/.well-known/.well-known/jwks.json
```

This service can also be extended to support key rotation.

* publicKeyIdentifier: returns the identifier (kid) of the public RSA key.
* privateKeyIdentifier: returns the identifier (kid) of the private RSA key.
* retrieveKey: returns key based on identifier 
* convertToJWK: convert the publicKey to JWKs. 
* (generateKey and storeKey not used in example)

### DiscoveryDocument:

Used to return the OpenID Connect Discovery Document.

```
/.well-known/openid-configuration
```

---

Additionally you need to set up session handling for user authentication:

Configuration.swift:

```
app.middleware.use(app.sessions.middleware, at: .beginning)

# In the example users are managed separately from OAuthUser

app.middleware.use(OAuthUserSessionAuthenticator())

app.middleware.use(MyUser.sessionAuthenticator())
```

Extension of `OAuthUser` to be authenticatable:

```
import Vapor
import VaporOAuth

extension OAuthUser: SessionAuthenticatable {

/// Store UserID (UUID) as sessionID
public var sessionID: String { self.id ?? "" }

}
```

```
import Vapor
import VaporOAuth
import Fluent

public struct OAuthUserSessionAuthenticator: AsyncSessionAuthenticator {
    public typealias User = OAuthUser

    public func authenticate(sessionID: String, for request: Vapor.Request) async throws { 

        // see example

    }
}
```

## Relying Party (client)

For a full documentation check the code example.

Add the following libraries if you want to support JWT tokens:

```
.package(url: "https://github.com/apple/swift-crypto.git", from: "3.1.0"),
.package(url: "https://github.com/vapor/jwt.git", from: "4.2.2")
```

```
.product(name: "Crypto", package: "swift-crypto"),
.product(name: "JWT", package: "jwt")
```


### Initiate Authorization Grant Flow:

```
func clientLogin(_ request: Request) async throws -> Response {

// …

let uri = "http://localhost:8090/oauth/authorize?client_id=\(content.client_id)&redirect_uri=\(content.redirect_uri)&scope=\(content.scope.joined(separator: ","))&response_type=\(content.response_type)&state=\(content.state)&code_challenge=\(content.code_challenge)&code_challenge_method=\(content.code_challenge_method)&nonce=\(nonce)"

return request.redirect(to: uri)

}
```

### Callback Authorization Grant Flow:

#### 1. Retrieve Authorization Code:

```
let code: String? = request.query["code"]
let state: String? = request.query["state"]
```

#### 2. Validate state parameter:

```
guard
    state == "ping-pong"
    else {
         throw(Abort(.badRequest, reason: "Validation of 'state' failed."))
      }
```

### 3. Request token:

```
let content = OAuth_TokenRequest(
         code: code,
         grant_type: "authorization_code",
         redirect_uri: "http://localhost:8089/callback",
         client_id: "1",
         client_secret: "password123",
         code_verifier: "hello_world"
      )

let tokenEndpoint = URI(string: "http://localhost:8090/oauth/token")
      
let response = try await request.client.post(tokenEndpoint, content: content)
```

#### 4. Retrieve public key and validate tokens:

```
let response = try await request.client.get("http://localhost:8090/.well-known/jwks.json")

let jwkSet = try response.content.decode(JWKS.self)

guard
    let jwks = jwkSet.find(identifier: JWKIdentifier(string: "public-key"))?.first,
    let modulus = jwks.modulus,
    let exponent = jwks.exponent,
    let publicKey = JWTKit.RSAKey(modulus: modulus, exponent: exponent)
else {
    throw Abort(.badRequest, reason: "JWK key could not be unpacked")
      }

let signers = JWTKit.JWTSigners()
      signers.use(.rs256(key: publicKey))

// Example Access Token:
payload = try signers.verify(token, as: Payload_AccessToken.self)

// Store tokens as cookies: see example

```

### Call oauth/token_info:

Basic Authentication

```
let content = OAuth_TokenIntrospectionRequest(
         token: access_token
      )

// Basic authentication credentials for request header
let resourceServerUsername = "resource-1"
let resourceServerPassword = "resource-1-password"
let credentials = "\(resourceServerUsername):\(resourceServerPassword)".base64String()

let headers = HTTPHeaders(dictionaryLiteral:
                                 ("Authorization", "Basic \(credentials)")
      )

let response = try await request.client.post(
         URI(string: "http://localhost:8090/oauth/token_info"),
         headers: headers,
         content: content
      )
```

### Call /oauth/userinfo:

Bearer authentication with Access Token:

```
let access_token: String? = request.cookies["access_token"]?.string

let headers = HTTPHeaders(dictionaryLiteral:
                                 ("Authorization", "Bearer \(access_token)")
      )

let response = try await request.client.get(
         URI(string: "http://localhost:8090/oauth/userinfo"),
         headers: headers
      )
```