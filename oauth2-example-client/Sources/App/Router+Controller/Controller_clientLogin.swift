import Vapor
import Leaf

extension Controller {

   func clientLogin(_ request: Request) async throws -> Response {

      let content = OAuth_AuthorizationRequest(
         client_id: "1",
         redirect_uri: "http://localhost:8089/callback",
         state: "ping-pong",
         response_type: "code",
         scope: ["admin"]
      )

      let uri = "http://localhost:8090/oauth/authorize?client_id=\(content.client_id)&redirect_uri=\(content.redirect_uri)&scope=\(content.scope.joined(separator: ","))&response_type=\(content.response_type)&state=\(content.state)"

#if DEBUG
      print("\n-----------------------------")
      print("Controller().login()")
      print("-----------------------------")
      print("Authorization request sent to oauth server:")
      print("URI: \(uri)")
      print("-----------------------------")
#endif

      return request.redirect(to: uri)

   }

}
