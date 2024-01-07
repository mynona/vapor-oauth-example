import Vapor
import Leaf
import JWTKit

extension Controller {

   /// Verify Access Token with oauth/token_info (introspection endpoint)
   ///
   /// - Parameters:
   ///   - enforceNewAccessToken: request new access_token regardless if an existing token was found or not
   ///
   func verifyAccessToken(enforceNewAccessToken: Bool = false, _ request: Request) async throws -> (introspection: OAuth_TokenIntrospectionResponse?, accessToken: String?, refreshToken: String?)? {

      // Get existing access_token from cookie
      var access_token: String? = request.cookies["access_token"]?.string
      var refresh_token: String? = request.cookies["refresh_token"]?.string

      // Request new access token if access_token cookie was not found OR
      // Enforce requesting a new access_token regardless of the cookie
      if access_token == nil || enforceNewAccessToken == true {

         do {
            let response = try await getNewToken(request)
            access_token = response.access_token
            refresh_token = response.refresh_token
         } catch  {
            return nil
         }

      }

      guard
         let access_token
      else {
         return nil
      }

      // -------------------------------------------------------
      // Call OpenID Provider endpoint
      // -------------------------------------------------------

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

#if DEBUG
      print("\n-----------------------------")
      print("Controller() \(#function)")
      print("-----------------------------")
      print("Token introspection request")
      print("Headers: \(headers)")
      print("Content: \(content)")
      print("-----------------------------")
#endif

      let response = try await request.client.post(
         URI(string: "http://localhost:8090/oauth/token_info"),
         headers: headers,
         content: content
      )

#if DEBUG
      print("\n-----------------------------")
      print("Controller() \(#function)")
      print("-----------------------------")
      print("Token introspection response:")
      print("Response: \(response)")
      print("-----------------------------")
#endif

      guard
         response.status == .ok
      else {
         // Introspection endpoint could not be reached
         return nil
      }

      // Unwrap response
      let introspection: OAuth_TokenIntrospectionResponse = try response.content.decode(OAuth_TokenIntrospectionResponse.self)

#if DEBUG
      print("\n-----------------------------")
      print("Controller() \(#function)")
      print("-----------------------------")
      print("Unwrapped response:")
      print("Introspection: \(introspection)")
      print("-----------------------------")
#endif

      return (introspection, access_token, refresh_token)
   }

   
}
