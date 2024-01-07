import Vapor
import Leaf

extension Controller {

   func userInfo(_ request: Request) async throws -> Response {

      let user = try await OAuthHelper.userInfo(request)

#if DEBUG
      print("\n-----------------------------")
      print("Controller() \(#function)")
      print("-----------------------------")
      print("Response /oauth/userinfo")
      print("name: \(user.name)")
      print("extend: \(user.extend)")
      print("-----------------------------")
#endif

      return request.redirect(to: "/introspection-test")

   }

}
