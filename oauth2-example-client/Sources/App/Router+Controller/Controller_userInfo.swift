import Vapor
import Leaf

extension Controller {

   func userInfo(_ request: Request) async throws -> Response {

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
      print("Controller() \(#function)")
      print("-----------------------------")
      print("Response /oauth/userinfo")
      print("\(response)")
      print("-----------------------------")
#endif


      return request.redirect(to: "/introspection-test")

   }

}
