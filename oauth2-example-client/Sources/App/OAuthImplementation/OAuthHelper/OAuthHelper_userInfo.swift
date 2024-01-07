import Vapor
import Leaf

extension OAuthHelper {

   static func userInfo(_ request: Request) async throws -> OAuth_UserInfoResponse {

      var access_token: String? = request.cookies["access_token"]?.string

      guard
         let access_token
      else {
         throw Abort(.badRequest, reason: "No access token cookie found.")
      }

      let headers = HTTPHeaders(dictionaryLiteral:
                                 ("Authorization", "Bearer \(access_token)")
      )

      let response = try await request.client.get(
         URI(string: "http://localhost:8090/oauth/userinfo"),
         headers: headers
      )

#if DEBUG
      print("\n-----------------------------")
      print("OAuthHelper() \(#function)")
      print("-----------------------------")
      print("\(response)")
      print("-----------------------------")
#endif

      let user = try response.content.decode(OAuth_UserInfoResponse.self)

      return user

   }

}
