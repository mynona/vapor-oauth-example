import Vapor

extension OAuthClient {

   /// Request new Access Token with Refresh Token
   ///
   /// - Throws: [OAuthClientErrors](x-source-tag://OAuthClientErrors)
   ///
   static func exchangeRefreshTokenForNewTokens(
      _ request: Request
   ) async throws -> OAuth_RefreshTokenResponse {

      // Get Refresh Token from Cookie
      guard
         let refreshToken = request.cookies["refresh_token"]?.string
      else {
         throw OAuthClientErrors.tokenCookieNotFound(.RefreshToken)
      }

      // Add basic authentication credentials to the request header
      let credentials = "\(resourceServerUsername):\(resourceServerPassword)".base64String()

      let headers = HTTPHeaders(dictionaryLiteral:
                                 ("Authorization", "Basic \(credentials)")
      )

      let content = OAuth_RefreshTokenRequest(
         grant_type: "refresh_token",
         client_id: "1",
         client_secret: "password123",
         refresh_token: refreshToken
      )

      let response = try await request.client.post(
         URI(string: "\(oAuthProvider)/oauth/token"),
         headers: headers,
         content: content
      )

#if DEBUG
      print("\n-----------------------------")
      print("OAuthClient() \(#function)")
      print("-----------------------------")
      print("Refresh token request header: \(headers)")
      print("-----------------------------")
      print("Refresh token response: \(response)")
      print("-----------------------------")
#endif

      guard
         response.status == .ok
      else {
         throw OAuthClientErrors.openIDProviderResponseError("\(response.status)")
      }

      let tokenResponse: OAuth_RefreshTokenResponse
      do {
         tokenResponse = try response.content.decode(OAuth_RefreshTokenResponse.self)
      } catch {
         throw OAuthClientErrors.validationError("Refresh Token response could not be decoded.")
      }

#if DEBUG
      print("\n-----------------------------")
      print("OAuthClient() \(#function)")
      print("-----------------------------")
      print("-----------------------------")
      print("Unwrapped: \(tokenResponse)")
      print("-----------------------------")
#endif

      // Verify Token Signature and Payload
      var tokenSet: [TokenType:String] = [:]
      tokenSet[.AccessToken] = tokenResponse.access_token

      if let refreshToken = tokenResponse.refresh_token {
         tokenSet[.RefreshToken] = refreshToken
      }

      do {
         _ = try await OAuthClient.validateJWT(
            forTokens: tokenSet,
            request
         )
      } catch {
         throw Abort(.badRequest, reason: "Error exchanging Code for Token")
      }

      return tokenResponse

   }

}

