import Vapor
import Leaf
import VaporOAuth
import Fluent

extension Controller {

   func logout(_ request: Request) async throws -> HTTPStatus {

      request.auth.logout(OAuthUser.self)
      request.auth.logout(MyUser.self)
      request.session.destroy()

      return .ok

   }

}
