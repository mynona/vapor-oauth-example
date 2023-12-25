import Vapor
import Leaf

extension Controller {

   func refreshToken(_ request: Request) async throws -> Response {

      guard
         let cookie = request.cookies["refresh_token"]
      else {
         throw(Abort(.badRequest, reason: "refresh-token cookie missing"))
      }

#if DEBUG
      print("\n-----------------------------")
      print("Controller().refreshTokenPage()")
      print("-----------------------------")
      print("Refresh token: \(cookie)")
      print("-----------------------------")
#endif

      // Basic authentication set up for the client to access the
      // introspection endpoint on the oauth server
      let resourceServerUsername = "resource-1"
      let resourceServerPassword = "resource-1-password"

      let credentials = "\(resourceServerUsername):\(resourceServerPassword)".base64String()

      let headers = HTTPHeaders(dictionaryLiteral:
                                 ("Authorization", "Basic \(credentials)")
      )

      let tokenEndpoint = URI(string: "http://localhost:8090/oauth/token")

      // A new token can only be retrieved with the client_secret

      let content = OAuth_RefreshTokenRequest(
         grant_type: "refresh_token",
         client_id: "1",
         client_secret: "password123",
         refresh_token: cookie.string
      )

      let response = try await request.client.post(tokenEndpoint, headers: headers, content: content)

#if DEBUG
      print("\n-----------------------------")
      print("Controller().refreshTokenPage()")
      print("-----------------------------")
      print("Refresh token endpoint: \(tokenEndpoint)")
      print("Refresh token request header: \(headers)")
      //print("Refresh token request content: \(content)")
      print("-----------------------------")
      print("Refresh token response: \(response)")
      print("-----------------------------")
#endif

      if response.status != .ok {
         throw(Abort(.unauthorized, reason: "Unauthorized"))
      }

      // Unwrap response
      let token: OAuth_RefreshTokenResponse = try response.content.decode(OAuth_RefreshTokenResponse.self)

#if DEBUG
      print("\n-----------------------------")
      print("Controller().refreshTokenPage()")
      print("-----------------------------")
      print("-----------------------------")
      print("Unwrapped: \(token)")
      print("-----------------------------")
#endif

      let view = try await request.view.render(
         "protected-page"
      )

      let res = try await view.encodeResponse(for: request)
      res.cookies["access_token"] = createCookie(value: token.access_token, for: .AccessToken)
      return res


   }

}

