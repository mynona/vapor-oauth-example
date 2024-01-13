import Vapor
import Leaf

extension OAuthClient {
   
   /// /oauth/userinfo
   ///
   /// The UserInfo Endpoint is an OAuth 2.0 Protected Resource that returns Claims about the authenticated End-User. To obtain the requested Claims about the End-User, the Client makes a request to the UserInfo Endpoint using an Access Token obtained through OpenID Connect Authentication. These Claims are normally represented by a JSON object that contains a collection of name and value pairs for the Claims.
   ///
   /// - Returns: Claims about authenticated End-User
   /// - Throws: [OAuthClientErrors](x-source-tag://OAuthClientErrors)
   ///
   static func userInfo(
      _ request: Request
   ) async throws -> OAuth_UserInfoResponse {
      
      guard
         let access_token: String = request.cookies["access_token"]?.string
      else {
         throw OAuthClientErrors.tokenCookieNotFound(.AccessToken)
      }
      
      let headers = HTTPHeaders(dictionaryLiteral:
                                 ("Authorization", "Bearer \(access_token)")
      )
      
      let response: ClientResponse
      do {
         response = try await request.client.get(
            URI(string: "\(oAuthProvider)/oauth/userinfo"),
            headers: headers
         )
      } catch {
         throw OAuthClientErrors.openIDProviderServerError
      }
      
#if DEBUG
      print("\n-----------------------------")
      print("OAuthClient() \(#function)")
      print("-----------------------------")
      print("\(response)")
      print("-----------------------------")
#endif
      
      guard
         response.status == .ok
      else {
         throw OAuthClientErrors.openIDProviderResponseError("\(response.status)")
      }
      
      let user: OAuth_UserInfoResponse
      do {
         user = try response.content.decode(OAuth_UserInfoResponse.self)
      } catch {
         throw OAuthClientErrors.dataDecodingError("OAuth_UserInfoResponse decoding failed.")
      }
      
      return user
      
   }
   
}
