import Vapor

extension Controller {

   /// getNewToken Error Codes
   ///
   /// - refreshTokenMissing: Cookie with Refresh Token could not be retrieved
   /// - openIDProviderError: OpenIDProvider response code not 200 OK
   /// - tokenDecodingError: OAuth_RefreshTokenResponse decoding failed
   /// - tokenValidationError: Verification of Refresh Token Signature and / or payload failed
   ///
   enum getNewTokenError: Error {
      case refreshTokenMissing
      case openIDProviderError
      case tokenDecodingError
      case tokenValidationError
   }


   /// Request new Access Token with Refresh Token
   ///
   /// - Throws: getNewTokenError
   ///
   func getNewToken(_ request: Request) async throws -> OAuth_RefreshTokenResponse {

      // Get Refresh Token from Cookie
      guard
         let refreshToken = request.cookies["refresh_token"]?.string
      else {
         throw getNewTokenError.refreshTokenMissing
      }

      // Validate Refresh Token Signature and Payload
      let jwtVerification: Bool
      do {
         jwtVerification = try await verifyJWT(
            forToken: refreshToken,
            tokenType: .RefreshToken,
            request
         )
      } catch verifyJWTError.openIDProviderError {
         throw getNewTokenError.openIDProviderError
      } catch {
         throw getNewTokenError.tokenValidationError
      }

      guard
         jwtVerification
      else {
         throw getNewTokenError.tokenValidationError
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
         URI(string: "http://localhost:8090/oauth/token"),
         headers: headers,
         content: content
      )

#if DEBUG
      print("\n-----------------------------")
      print("Controller() \(#function)")
      print("-----------------------------")
      print("Refresh token request header: \(headers)")
      print("-----------------------------")
      print("Refresh token response: \(response)")
      print("-----------------------------")
#endif

      guard
         response.status == .ok
      else {
         throw getNewTokenError.openIDProviderError
      }

      do {
         let token: OAuth_RefreshTokenResponse = try response.content.decode(OAuth_RefreshTokenResponse.self)

#if DEBUG
      print("\n-----------------------------")
      print("Controller() \(#function)")
      print("-----------------------------")
      print("-----------------------------")
      print("Unwrapped: \(token)")
      print("-----------------------------")
#endif

         return token
      } catch {
         throw getNewTokenError.tokenDecodingError
      }

   }

}
