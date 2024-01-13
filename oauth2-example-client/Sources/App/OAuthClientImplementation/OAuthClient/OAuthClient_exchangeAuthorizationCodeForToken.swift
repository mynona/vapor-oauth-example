import Vapor

extension OAuthClient {

   /// Open ID Provider redirects back to the specified redirect_uri with the code and the state.
   ///
   /// Step 1: Get authorization code and state
   /// - Client receives the authorization code and state
   /// - Client checks if the state matches the state value sent to the provider
   ///
   /// Step 2: Exchange code for tokens
   /// - Client sends the code back to the token endpoints of the provider to retrieve the access_token, refresh_token and id_token
   /// - Client validates signature and payload of tokens
   ///
   /// - Throws: [OAuthClientErrors](x-source-tag://OAuthClientErrors)
   ///
   static func exchangeAuthorizationCodeForTokens(
      _ request: Request
   ) async throws -> (
      accessToken: String?,
      refreshToken: String?,
      idToken: String?
   ) {

#if DEBUG
      print("\n-----------------------------")
      print("OAuthClient() \(#function)")
      print("-----------------------------")
      print("Request: \(request)")
      print("-----------------------------")
#endif

      // -------------------------------------------------------
      // Step 1: Get authorization code and state
      // -------------------------------------------------------

      guard
         let code: String = request.query["code"]
      else {
         throw OAuthClientErrors.authorizationFlowParameterMissing(
            "Required query parameter 'code' missing."
         )
      }

      guard
         let state: String = request.query["state"]
      else {
         throw OAuthClientErrors.authorizationFlowParameterMissing(
            "Required query parameter 'state' missing."
         )
      }

      // State correct?
      guard
         state == stateVerifier
      else {
         throw OAuthClientErrors.validationError(
            "Validation of query parameter 'state' failed."
         )
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

      // -------------------------------------------------------
      // Step 2: Exchange code for tokens
      // -------------------------------------------------------

      let content = OAuthClientTokenRequest(
         code: code,
         grant_type: "authorization_code",
         redirect_uri: "\(callbackURL)/callback",
         client_id: clientID,
         client_secret: clientSecret,
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

      guard
         response.status == .ok
      else {
         throw OAuthClientErrors.openIDProviderResponseError(
            "\(response.status)"
         )
      }

      let authorizationResponse: OAuthClientAuthorizationResponse
      do {
         authorizationResponse = try response.content.decode(
            OAuthClientAuthorizationResponse.self
         )
      } catch {
         throw OAuthClientErrors.dataDecodingError(
            "OAuth_AuthorizationResponse decoding failed."
         )
      }

      // Validate Tokens
      var tokenSet: [TokenType:String] = [:]
      if let accessToken = authorizationResponse.accessToken {
         tokenSet[.AccessToken] = accessToken
      }

      if let refreshToken = authorizationResponse.refreshToken {
         tokenSet[.RefreshToken] = refreshToken
      }

      if let idToken = authorizationResponse.idToken {
         tokenSet[.IDToken] = idToken
      }

      // No error handling -> propagate potential valiation error to caller function
      _ = try await OAuthClient.validateJWT(forTokens: tokenSet, request)

      return (
         accessToken: authorizationResponse.accessToken,
         refreshToken: authorizationResponse.refreshToken,
         idToken: authorizationResponse.idToken
      )

   }

}

