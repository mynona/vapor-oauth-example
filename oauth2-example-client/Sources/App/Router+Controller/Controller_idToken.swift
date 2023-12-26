import Vapor
import Leaf

extension Controller {



   // NOT IMPLEMENTED YET AS PART OF
   // vapor/oauth

   // Ignore below code. Doesn't work yet





   func idToken(_ request: Request) async throws -> Response {


      guard
         let cookie = request.cookies["refresh_token"]
      else {
         throw(Abort(.badRequest, reason: "Cookie 'refresh-token' missing."))
      }

#if DEBUG
      print("\n-----------------------------")
      print("Controller() \(#function)")
      print("-----------------------------")
      print("Access token: \(cookie)")
      print("-----------------------------")
#endif

      let nonce = "nonce-test"
      let refresh_token = cookie.string

      let content = OAuth_IDTokenRequest(
         grant_type: "id_token",
         client_id: "1",
         client_secret: "password123",
         nonce: nonce
      )

      let tokenEndpoint = URI(string: "http://localhost:8090/oauth/token")

      let headers = HTTPHeaders(dictionaryLiteral:
                                 ("Authorization", "Bearer \(refresh_token)")
      )

      let response = try await request.client.post(tokenEndpoint, headers: headers, content: content)

#if DEBUG
      print("\n-----------------------------")
      print("Controller() \(#function)")
      print("-----------------------------")
      print("Response: \(response)")
      print("-----------------------------")
#endif

      return request.redirect(to: "http://localhost:8089")
   }

}
