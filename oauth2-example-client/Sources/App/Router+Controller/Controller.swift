import Vapor
import Leaf

struct Controller: Encodable {

   func home(_ request: Request) async throws -> View {
      return try await request.view.render("index")
   }

   // ----------------------------------------------------------

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

   // ----------------------------------------------------------

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


      // for the sake of this test run duration is set wrongly
      // duration would be set as the duration of the token

      let duration = 600;

      let accessTokenCookie = HTTPCookies.Value(
         string: accessToken,
         expires: Date(timeIntervalSinceNow: TimeInterval(duration)),
         maxAge: duration,
         domain: nil,
         path: nil,
         isSecure: false, // in real world case: true
         isHTTPOnly: false, // in real world case: true
         sameSite: nil
      )

      let refreshTokenCookie = HTTPCookies.Value(
         string: refreshToken,
         expires: Date(timeIntervalSinceNow: TimeInterval(duration)),
         maxAge: duration,
         domain: nil,
         path: nil,
         isSecure: false, // in real world case: true
         isHTTPOnly: false, // in real world case: true
         sameSite: nil
      )

      let view = try await request.view.render(
         "success"
      )

      let res = try await view.encodeResponse(for: request)
      res.cookies["access_token"] = accessTokenCookie
      res.cookies["refresh_token"] = refreshTokenCookie
      return res

   }

   // ----------------------------------------------------------

   func protectedPage(_ request: Request) async throws -> View {

      // Get access token from cookie

      guard
         let cookie = request.cookies["access_token"]
      else {

#if DEBUG
      print("\n-----------------------------")
      print("Controller().protectedPage()")
      print("-----------------------------")
      print("Unauthorized because access token cookie is missing")
      print("-----------------------------")
#endif

         guard
            let cookie = request.cookies["refresh_token"]
         else {
            return try await request.view.render("unauthorized")
         }

#if DEBUG
      print("\n-----------------------------")
      print("Controller().protectedPage() -> refreshToken")
      print("-----------------------------")
      print("Refresh token: \(cookie)")
      print("-----------------------------")
#endif

         // Basic authentication set up for the client to access the
         // introspection endpoint on the oauth server
         let resourceServerUsername = "test"
         let resourceServerPassword = "test"

         let credentials = "\(resourceServerUsername):\(resourceServerPassword)".base64String()

         let headers = HTTPHeaders(dictionaryLiteral:
                                    ("Authorization", "Basic \(credentials)")
                                   )

         let tokenEndpoint = URI(string: "http://localhost:8090/oauth/token")

         let content = OAuth_RefreshTokenRequest(
            grant_type: "authorization_code",
            client_id: "1",
            client_secret: "password123",
            refresh_token: cookie.string
         )

         let response = try await request.client.post(tokenEndpoint, headers: headers, content: content)

#if DEBUG
      print("\n-----------------------------")
      print("Controller().protectedPage() -> refreshToken")
      print("-----------------------------")
      print("Refresh token endpoint: \(tokenEndpoint)")
      print("Refresh token request header: \(headers)")
      print("Refresh token request content: \(content)")
      print("-----------------------------")
      print("Refresh token response: \(response)")
      print("-----------------------------")
#endif

         return try await request.view.render("unauthorized")

      }

      // -------------------------------------------------------

      // Token introspection to check if a valid token has been
      // provided

      let accessToken = cookie.string

      let content = OAuth_TokenIntrospectionRequest(
         token: accessToken
      )

      // Basic authentication set up for the client to access the
      // introspection endpoint on the oauth server
      let resourceServerUsername = "test"
      let resourceServerPassword = "test"

      let credentials = "\(resourceServerUsername):\(resourceServerPassword)".base64String()

      let headers = HTTPHeaders(dictionaryLiteral:
                                 ("Authorization", "Basic \(credentials)")
                                )

#if DEBUG
      print("\n-----------------------------")
      print("Controller().protectedPage()")
      print("-----------------------------")
      print("Token introspection request")
      print("Headers: \(headers)")
      print("Content: \(content)")
      print("-----------------------------")
#endif

      let tokenEndpoint = URI(string: "http://localhost:8090/oauth/token_info")
      let response = try await request.client.post(tokenEndpoint, headers: headers, content: content)

#if DEBUG
      print("\n-----------------------------")
      print("Controller().protectedPage()")
      print("-----------------------------")
      print("Token introspection response:")
      print("Response: \(response)")
      print("-----------------------------")
#endif

      // Unwrap response

      let introspection: OAuth_TokenIntrospectionResponse = try response.content.decode(OAuth_TokenIntrospectionResponse.self)

#if DEBUG
      print("\n-----------------------------")
      print("Controller().protectedPage()")
      print("-----------------------------")
      print("Unwrapped response::")
      print("Introspection: \(introspection)")
      print("-----------------------------")
#endif

      // Invalid access token

      if introspection.active == false {
            return try await request.view.render("unauthorized")
         }




      // Valid access token

      return try await request.view.render("protected-page")
   }


}
