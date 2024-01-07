import Vapor
import Leaf

extension Controller {

   func clientLogout(_ request: Request) async throws -> Response {

      return try await OAuthHelper.logout(request)

   }

}
