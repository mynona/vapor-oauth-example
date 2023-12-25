import Vapor
import Leaf

extension Controller {

   /// Token introspection flow when accessing a protected resource
   ///
   /// Endpoint /oauth/token is called with Basic Authentication to check if the access_token is valid
   /// - valid: show page
   /// - invalid: show unauthorized page
   ///
   func introspection(_ request: Request) async throws -> View {

      // Get access token from cookie
      guard
         let cookie = request.cookies["access_token"]
      else {

#if DEBUG
         print("\n-----------------------------")
         print("Controller() \(#function)")
         print("-----------------------------")
         print("Unauthorized because access token cookie is missing")
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

      // Add basic authentication credentials to the request header
      let resourceServerUsername = "resource-1"
      let resourceServerPassword = "resource-1-password"
      let credentials = "\(resourceServerUsername):\(resourceServerPassword)".base64String()

      let headers = HTTPHeaders(dictionaryLiteral:
                                 ("Authorization", "Basic \(credentials)")
      )

#if DEBUG
      print("\n-----------------------------")
      print("Controller() \(#function)")
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
      print("Controller() \(#function)")
      print("-----------------------------")
      print("Token introspection response:")
      print("Response: \(response)")
      print("-----------------------------")
#endif

      guard
         response.status == .ok
      else {
         return try await request.view.render("unauthorized")
      }

      // Unwrap response
      let introspection: OAuth_TokenIntrospectionResponse = try response.content.decode(OAuth_TokenIntrospectionResponse.self)

#if DEBUG
      print("\n-----------------------------")
      print("Controller() \(#function)")
      print("-----------------------------")
      print("Unwrapped response::")
      print("Introspection: \(introspection)")
      print("-----------------------------")
#endif

      // Invalid access token
      guard
         introspection.active == true
      else {
         return try await request.view.render("unauthorized")
      }

      return try await request.view.render("introspection-success")
   }

}
