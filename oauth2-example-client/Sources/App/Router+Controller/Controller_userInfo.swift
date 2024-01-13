import Vapor
import Leaf

extension Controller {

   func userInfo(_ request: Request) async throws -> Response {

      let user: OAuthClientUserInfoResponse
      do {
         user = try await OAuthClient.userInfo(request) }
      catch {

#if DEBUG
         print("\n-----------------------------")
         print("Controller() \(#function)")
         print("-----------------------------")
         print("call to /oauth/userinfo failed")
         print("-----------------------------")
#endif

         return request.redirect(to: "http://localhost:8089/unauthorized")

      }

      return try await request.view.render(
         "userinfo",
         UserInfo(user: user)
      ).encodeResponse(for: request)

   }

}
