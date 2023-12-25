import Vapor
import Leaf

extension Controller {

   /// Open ID Provider redirects back to the specified redirect_uri with the code and the state.
   ///
   /// Step 1:
   /// - Client receives the authorization code and state
   /// - Client checks if the state matches the state value sent to the provider
   ///
   /// Step 2:
   /// - Client sends the code back to the token endpoints of the provider to retrieve the access_token and refresh_token
   ///
   func callback(_ request: Request) async throws -> Response {

#if DEBUG
      print("\n-----------------------------")
      print("Controller() \(#function)")
      print("-----------------------------")
      print("Request: \(request)")
      print("-----------------------------")
#endif

      // 1. Get authorization code and state

      let code: String? = request.query["code"]
      let state: String? = request.query["state"]

      // Code and state returned?
      guard
         let code,
         let state
      else {
         throw(Abort(.badRequest, reason: "No 'code' or 'state' value returned from provider."))
      }

      // State correct?
      guard
         state == "ping-pong"
      else {
         throw(Abort(.badRequest, reason: "Validation of 'state' failed."))
      }

#if DEBUG
      print("\n-----------------------------")
      print("Controller() \(#function)")
      print("-----------------------------")
      print("Authorization code received from oauth server:")
      print("Code: \(code)")
      print("State: \(state)")
      print("-----------------------------")
#endif

      // 2. Request token with authorization code

      let content = OAuth_TokenRequest(
         code: code,
         grant_type: "authorization_code",
         redirect_uri: "http://localhost:8089/callback",
         client_id: "1",
         client_secret: "password123",
         code_verifier: "hello_world"
      )

      let tokenEndpoint = URI(string: "http://localhost:8090/oauth/token")
      let response = try await request.client.post(tokenEndpoint, content: content)

#if DEBUG
      print("\n-----------------------------")
      print("Controller() \(#function)")
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
      res.cookies["access_token"] = createCookie(value: accessToken, for: .AccessToken)
      res.cookies["refresh_token"] = createCookie(value: refreshToken, for: .RefreshToken)
      return res

   }

}
