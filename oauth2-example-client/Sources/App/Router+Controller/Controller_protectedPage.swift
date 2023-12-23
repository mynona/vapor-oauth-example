import Vapor
import Leaf

extension Controller {

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
      // On the oauth server acess is managed via:
      // resourceServerRetriever: LiveResourceServerRetriever(app: app)
      let resourceServerUsername = "resource-1"
      let resourceServerPassword = "resource-1-password"

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


      if response.status != .ok {
         return try await request.view.render("unauthorized")
      }


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
