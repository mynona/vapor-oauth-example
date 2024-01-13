import Vapor

extension OAuthClient {


   /// Open ID Provider redirects back to the specified redirect_uri with the code and the state.
   ///
   /// Step 1:
   /// - Client receives the authorization code and state
   /// - Client checks if the state matches the state value sent to the provider
   ///
   /// Step 2:
   /// - Client sends the code back to the token endpoints of the provider to retrieve the access_token, refresh_token and id_token
   /// - Client validates signature and payload of tokens
   ///
   static func exchangeAuthorizationCodeForToken(_ request: Request) async throws -> (accessToken: String?, refreshToken: String?, idToken: String?) {

#if DEBUG
      print("\n-----------------------------")
      print("OAuthClient() \(#function)")
      print("-----------------------------")
      print("Request: \(request)")
      print("-----------------------------")
#endif

      // 1. Get authorization code and state

      let code: String? = request.query["code"]
      let state: String? = request.query["state"]

      // Code and state returned?
      guard
         let code,
         let state
      else {
         throw(Abort(.badRequest, reason: "No 'code' or 'state' value returned from provider."))
      }

      // State correct?
      guard
         state == stateVerifier
      else {
         throw(Abort(.badRequest, reason: "Validation of 'state' failed."))
      }

#if DEBUG
      print("\n-----------------------------")
      print("OAuthClient() \(#function)")
      print("-----------------------------")
      print("Authorization code received from oauth server:")
      print("Code: \(code)")
      print("State: \(state)")
      print("-----------------------------")
#endif

      // 2. Request token with authorization code

      let content = OAuth_TokenRequest(
         code: code,
         grant_type: "authorization_code",
         redirect_uri: "\(callbackURL)/callback",
         client_id: "1",
         client_secret: "password123",
         code_verifier: codeVerifier
      )

      let tokenEndpoint = URI(string: "\(oAuthProvider)/oauth/token")
      let response = try await request.client.post(tokenEndpoint, content: content)

#if DEBUG
      print("\n-----------------------------")
      print("OAuthClient() \(#function)")
      print("-----------------------------")
      print("Response received from oauth server:")
      print("Response: \(response)")
      print("-----------------------------")
#endif

      // Throw error if token could not be retrieved
      guard
         response.status == .ok
      else {
         throw(Abort(response.status))
      }

      let expiryInMinutes = try response.content.get(Int.self, at: "expires_in")
      let accessToken = try? response.content.get(String.self, at: "access_token")
      let refreshToken = try? response.content.get(String.self, at: "refresh_token")
      let idToken = try? response.content.get(String.self, at: "id_token")
      let scope = try response.content.get(String.self, at: "scope")

      // Validate Tokens
      var tokenSet: [TokenType:String] = [:]
      if let accessToken {
         tokenSet[.AccessToken] = accessToken
      }

      if let refreshToken {
         tokenSet[.RefreshToken] = refreshToken
      }

      if let idToken {
         tokenSet[.IDToken] = idToken
      }

      guard
         try await OAuthClient.validateJWT(forTokens: tokenSet, request)
      else {
         throw Abort(
            .badRequest,
            reason: "Validation of Token signature and payload failed."
         )
      }

      return (
         accessToken: accessToken,
         refreshToken: refreshToken,
         idToken: idToken
      )

   }

}
