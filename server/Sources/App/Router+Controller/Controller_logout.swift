import Vapor
import Leaf
import VaporOAuth
import Fluent

extension Controller {

   func logout(_ request: Request) async throws -> HTTPStatus {

#if DEBUG
      print("\n-----------------------------")
      print("Controller() \(#function)")
      print("-----------------------------")
      print("Called with parameters:")
      print("request: \(request)")
      print("-----------------------------")
#endif

      request.auth.logout(OAuthUser.self)
      request.auth.logout(UserModel.self)
      request.session.destroy()

      return .ok

   }

}
