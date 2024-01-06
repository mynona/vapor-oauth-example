import Vapor
import Leaf

extension Controller {

   enum RequestAccessTokenError: Error {
      case refreshTokenMissing
      case openIDServerError
      case refreshTokenDecodingError
      case refreshTokenValidationError
   }


   /// Request new Access Token with Refresh Token.
   ///
   func requestNewAccessToken(_ request: Request) async throws -> OAuth_RefreshTokenResponse {

      // Get Refresh Token from Cookie
      guard
         let refreshToken = request.cookies["refresh_token"]?.string
      else {
         throw RequestAccessTokenError.refreshTokenMissing
      }

      // Validate Refresh Token Signature and Payload
      guard
         try await verifyJWT(forToken: refreshToken, tokenType: .RefreshToken, request)
      else {
         throw RequestAccessTokenError.refreshTokenValidationError
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
         throw RequestAccessTokenError.openIDServerError
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
         throw RequestAccessTokenError.refreshTokenDecodingError
      }

   }

}
