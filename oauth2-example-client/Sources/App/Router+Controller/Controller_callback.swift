import Vapor
import Leaf

extension Controller {

   func callback(_ request: Request) async throws -> Response {

      // Step 1: Authorization code

      guard
         let code = request.query[String.self, at: "code"]
      else {

         throw(Abort(.badRequest, reason: "Invalid authorization code"))
      }

#if DEBUG
      print("\n-----------------------------")
      print("Controller().callback()")
      print("-----------------------------")
      print("Authorization code received from oauth server:")
      print("Request: \(request)")
      print("-----------------------------")
#endif

      // Step 2: Request token with authorization code

      let content = OAuth_TokenRequest(
         code: code,
         grant_type: "authorization_code",
         redirect_uri: "http://localhost:8089/callback",
         client_id: "1",
         client_secret: "password123"
      )

      let tokenEndpoint = URI(string: "http://localhost:8090/oauth/token")

      let response = try await request.client.post(tokenEndpoint, content: content)

#if DEBUG
      print("\n-----------------------------")
      print("Controller().callback()")
      print("-----------------------------")
      print("Response received from oauth server:")
      print("Response: \(response)")
      print("-----------------------------")
#endif

      // Throw error if token could not be retrieved
      guard
         response.status == .ok
      else {
         throw(Abort(response.status))
      }

      let expiryInMinutes = try response.content.get(Int.self, at: "expires_in")
      let accessToken = try response.content.get(String.self, at: "access_token")
      let refreshToken = try response.content.get(String.self, at: "refresh_token")
      let scope = try response.content.get(String.self, at: "scope")

      // Token rotation is not supported in vapor/oauth at the moment:
      // https://stateful.com/blog/oauth-refresh-token-best-practices

      let view = try await request.view.render(
         "success"
      )

      let res = try await view.encodeResponse(for: request)
      res.cookies["access_token"] = createCookie(token: accessToken, for: .AccessToken)
      res.cookies["refresh_token"] = createCookie(token: refreshToken, for: .RefreshToken)
      return res

   }

}
