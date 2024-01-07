import Vapor
import Leaf
import JWTKit

extension OAuthHelper {

   public enum IntrospectionError: Error {

      /// OpenID Provider response status was not 200 OK
      case openIDProviderError
      /// OAuth_TokenIntrospectionResponse decoding failed
      case decodingError

   }

   /// Validate Access Token with `oauth/token_info` (introspection endpoint)
   ///
   static func introspect(accessToken access_token: String, _ request: Request) async throws -> OAuth_TokenIntrospectionResponse {

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
      print("OAuthHelper() \(#function)")
      print("-----------------------------")
      print("Token introspection request")
      print("Headers: \(headers)")
      print("Content: \(content)")
      print("-----------------------------")
#endif

      let response = try await request.client.post(
         URI(string: "\(oAuthProvider)/oauth/token_info"),
         headers: headers,
         content: content
      )

#if DEBUG
      print("\n-----------------------------")
      print("OAuthHelper() \(#function)")
      print("-----------------------------")
      print("Token introspection response:")
      print("Response: \(response)")
      print("-----------------------------")
#endif

      guard
         response.status == .ok
      else {
         throw IntrospectionError.openIDProviderError
      }

      do {
         let introspection: OAuth_TokenIntrospectionResponse = try response.content.decode(OAuth_TokenIntrospectionResponse.self)

#if DEBUG
         print("\n-----------------------------")
         print("OAuthHelper() \(#function)")
         print("-----------------------------")
         print("Unwrapped response:")
         print("Introspection: \(introspection)")
         print("-----------------------------")
#endif

         return introspection

      } catch {
         throw IntrospectionError.decodingError
      }
   }

}
