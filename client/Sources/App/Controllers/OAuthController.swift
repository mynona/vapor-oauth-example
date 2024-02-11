import Vapor

struct OAuthController: RouteCollection {
   let oauthClient: OAuthClient

   init() {
      self.oauthClient = OAuthClient(
         oAuthProviderURL: OAuthConstants.oAuthProvider,
         callbackURL: OAuthConstants.callbackURL,
         clientID: OAuthConstants.clientID,
         clientSecret: OAuthConstants.clientSecret,
         resourceServerUsername: OAuthConstants.resourceServerUsername,
         resourceServerPassword: OAuthConstants.resourceServerPassword,
         serverSessionCookieName: OAuthConstants.serverSessionCookieName,
         stateVerifier: OAuthConstants.stateVerifier,
         codeVerifier: OAuthConstants.codeVerifier,
         nonce: OAuthConstants.nonce
      )
   }

   func boot(routes: RoutesBuilder) throws {
      let oauth = routes.grouped("auth")
      oauth.get("login", use: clientLogin)
      oauth.get("callback", use: callback)
      oauth.get("introspection", use: introspection)
      oauth.get("userinfo", use: userInfo)
      oauth.get("logout", use: clientLogout)
      oauth.get("unauthorized", use: unauthorized)
      oauth.get(use: home)
   }

   func home(_ request: Request) async throws -> View {
      return try await request.view.render("index")
   }

   func clientLogin(_ request: Request) async throws -> Response {
      return try await oauthClient.requestAuthorizationCode(request)
   }

   func callback(_ request: Request) async throws -> Response {
      let token = try await oauthClient.exchangeAuthorizationCodeForTokens(request)

      let view = try await request.view.render(
         "protected-resource"
      )

      let response = try await view.encodeResponse(for: request)

      // Prepare a JSON response with token information
      //var responseData: [String: String] = [:]
      if let accessToken = token.accessToken {
         //responseData["access_token"] = accessToken
         // Create and set the access token cookie
         response.cookies["access_token"] = oauthClient.cookieManager.createCookie(
            withValue: accessToken,
            forToken: .AccessToken,
            environment: request.application.environment
         )
      }

      if let refreshToken = token.refreshToken {
         //responseData["refresh_token"] = refreshToken
         // Create and set the refresh token cookie
         response.cookies["refresh_token"] = oauthClient.cookieManager.createCookie(
            withValue: refreshToken,
            forToken: .RefreshToken,
            environment: request.application.environment
         )
      }

      if let idToken = token.idToken {
         //responseData["id_token"] = idToken
         // Create and set the ID token cookie
         response.cookies["id_token"] = oauthClient.cookieManager.createCookie(
            withValue: idToken,
            forToken: .IDToken,
            environment: request.application.environment
         )
      }

      // Encode the response data to JSON and return the response
      //let response = Response(status: .ok, headers: .init(), body: .init())
      //try response.content.encode(responseData, as: .json)

      return response
   }

   func introspection(_ request: Request) async throws -> Response {

      guard
         let accessToken: String = request.cookies["access_token"]?.string
      else {
         print("No access Token found")
         return request.redirect(to: "unauthorized")
      }

      var introspection = try await oauthClient.introspect(accessToken: accessToken, request)

      guard
         introspection.active
      else {

         // if introspection failed try to get new access token with refresh token
         let result = try await oauthClient.exchangeRefreshTokenForNewTokens(request)
         print(result)


         return request.redirect(to: "unauthorized")
      }

      // Safely unwrap the optional 'scope' or provide a default value
      let scopes = introspection.scope ?? ""
      if !oauthClient.validateScope(requiredScopes: "openid", retrievedScopes: scopes) {
         return request.redirect(to: "unauthorized")
      }

      let view = try await request.view.render("protected-resource")
      return try await view.encodeResponse(for: request)
   }

   func userInfo(_ request: Request) async throws -> Response {
      let user = try await oauthClient.userInfo(request)
      return try await request.view.render("userinfo", ["user": user]).encodeResponse(for: request)
   }

   func clientLogout(_ request: Request) async throws -> Response {
      return try await oauthClient.logout(request, redirectURL: "index")

   }

   func unauthorized(_ request: Request) async throws -> Response {
      let view = try await request.view.render("unauthorized")
      return try await view.encodeResponse(for: request)
   }

}
