import Vapor

extension OAuthHelper {

   public enum TokenExchangeError: Error {

      /// Refresh Token cookie could not be retrieved from request
      case refreshTokenMissing
      /// OpenID Provider response for /oauth/token was not 200 OK
      case openIDProviderError
      /// OAuth_RefreshTokenResponse decoding failed
      case tokenResponseDecodingError
      /// JWK could not be retrieved from OpenID Provider or decoding failed
      case jwkError
      /// Verification of JWT signature or payload failed
      case tokenValidationError
   }


   /// Request new Access Token with Refresh Token
   ///
   /// - Throws: `tokenExchangeError`
   ///
   static func exchangeRefreshTokenForNewTokens(_ request: Request) async throws -> OAuth_RefreshTokenResponse {

      // Get Refresh Token from Cookie
      guard
         let refreshToken = request.cookies["refresh_token"]?.string
      else {
         throw TokenExchangeError.refreshTokenMissing
      }

      // Add basic authentication credentials to the request header
      let resourceServerUsername = "resource-1"
      let resourceServerPassword = "resource-1-password"
      let credentials = "\(resourceServerUsername):\(resourceServerPassword)".base64String()

      let headers = HTTPHeaders(dictionaryLiteral:
                                 (
                                    "Authorization", "Basic \(credentials)"
                                 )
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
      print("OAuthHelper() \(#function)")
      print("-----------------------------")
      print("Refresh token request header: \(headers)")
      print("-----------------------------")
      print("Refresh token response: \(response)")
      print("-----------------------------")
#endif

      guard
         response.status == .ok
      else {
         throw TokenExchangeError.openIDProviderError
      }

      let tokenResponse: OAuth_RefreshTokenResponse
      do {
         tokenResponse = try response.content.decode(OAuth_RefreshTokenResponse.self)
      } catch {
         throw TokenExchangeError.tokenResponseDecodingError
      }

#if DEBUG
      print("\n-----------------------------")
      print("OAuthHelper() \(#function)")
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
         _ = try await OAuthHelper.validateJWT(forTokens: tokenSet, request)
      } catch ValidateJWTError.openIDProviderError {
         throw TokenExchangeError.openIDProviderError
      } catch ValidateJWTError.jwkDecodingError,
              ValidateJWTError.jwkSetDecodingError,
              ValidateJWTError.jwkMissing {
         throw TokenExchangeError.jwkError
      } catch {
         throw TokenExchangeError.tokenValidationError
      }

      return tokenResponse

   }

}
