import Vapor
import Leaf
import JWTKit

extension OAuthClient {

   /// Validate Access Token with `oauth/token_info` (introspection endpoint)
   ///
   /// - Throws: [OAuthClientErrors](x-source-tag://OAuthClientErrors)
   ///
   static func introspect(
      accessToken access_token: String,
      _ request: Request
   ) async throws -> OAuthClientTokenIntrospectionResponse {

      let content = OAuthClientTokenIntrospectionRequest(
         token: access_token
      )

      // Basic authentication credentials for request header
      let credentials = "\(resourceServerUsername):\(resourceServerPassword)".base64String()

      let headers = HTTPHeaders(dictionaryLiteral:
                                 ("Authorization", "Basic \(credentials)")
      )

#if DEBUG
      print("\n-----------------------------")
      print("OAuthClient() \(#function)")
      print("-----------------------------")
      print("Token introspection request")
      print("Headers: \(headers)")
      print("Content: \(content)")
      print("-----------------------------")
#endif

      let response: ClientResponse
      do {
         response = try await request.client.post(
            URI(string: "\(oAuthProvider)/oauth/token_info"),
            headers: headers,
            content: content
         )
      } catch {
         throw OAuthClientErrors.openIDProviderServerError
      }

#if DEBUG
      print("\n-----------------------------")
      print("OAuthClient() \(#function)")
      print("-----------------------------")
      print("Token introspection response:")
      print("Response: \(response)")
      print("-----------------------------")
#endif

      guard
         response.status == .ok
      else {
         throw OAuthClientErrors.openIDProviderResponseError(
            "\response.status)"
         )
      }

      do {
         let introspection: OAuthClientTokenIntrospectionResponse = try response.content.decode(
            OAuthClientTokenIntrospectionResponse.self
         )

#if DEBUG
         print("\n-----------------------------")
         print("OAuthClient() \(#function)")
         print("-----------------------------")
         print("Unwrapped response:")
         print("Introspection: \(introspection)")
         print("-----------------------------")
#endif
         
         return introspection

      } catch {
         throw OAuthClientErrors.dataDecodingError(
            "OAuth_TokenIntrospectionResponse decoding failed."
         )
      }
   }

}
