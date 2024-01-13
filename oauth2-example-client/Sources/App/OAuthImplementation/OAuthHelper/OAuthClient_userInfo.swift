import Vapor
import Leaf

extension OAuthClient {
   
   /// Calls endpoint: /oauth/userinfo
   ///
   /// - Returns: Information about user
   /// - Throws: UserInfoErrors
   ///
   static func userInfo(
      _ request: Request
   ) async throws -> OAuth_UserInfoResponse {
      
      guard
         let access_token: String = request.cookies["access_token"]?.string
      else {
         throw OAuthClientErrors.noAccessTokenCookieFound
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
         throw OAuthClientErrors.openIDProviderNoResponse
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
         throw OAuthClientErrors.openIDProviderError(response.status)
      }
      
      let user: OAuth_UserInfoResponse
      do {
         user = try response.content.decode(OAuth_UserInfoResponse.self)
      } catch {
         throw OAuthClientErrors.dataDecodingError
      }
      
      return user
      
   }
   
}
