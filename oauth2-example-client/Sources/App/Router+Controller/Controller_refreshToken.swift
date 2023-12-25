import Vapor
import Leaf

extension Controller {
   
   /// Obtain a new refresh_token from the Open ID provider
   ///
   /// Endpoint /oauth/token is called with Basic Authentication 
   ///
   func refreshToken(_ request: Request) async throws -> Response {
      
      guard
         let cookie = request.cookies["refresh_token"]
      else {
         throw(Abort(.badRequest, reason: "Cookie 'refresh-token' missing."))
      }
      
#if DEBUG
      print("\n-----------------------------")
      print("Controller() \(#function)")
      print("-----------------------------")
      print("Refresh token: \(cookie)")
      print("-----------------------------")
#endif
      
      // Add basic authentication credentials to the request header
      let resourceServerUsername = "resource-1"
      let resourceServerPassword = "resource-1-password"
      let credentials = "\(resourceServerUsername):\(resourceServerPassword)".base64String()
      
      let headers = HTTPHeaders(dictionaryLiteral:
                                 ("Authorization", "Basic \(credentials)")
      )
      
      let tokenEndpoint = URI(string: "http://localhost:8090/oauth/token")
      
      let content = OAuth_RefreshTokenRequest(
         grant_type: "refresh_token",
         client_id: "1",
         client_secret: "password123",
         refresh_token: cookie.string
      )
      
      let response = try await request.client.post(tokenEndpoint, headers: headers, content: content)
      
#if DEBUG
      print("\n-----------------------------")
      print("Controller() \(#function)")
      print("-----------------------------")
      print("Refresh token endpoint: \(tokenEndpoint)")
      print("Refresh token request header: \(headers)")
      print("-----------------------------")
      print("Refresh token response: \(response)")
      print("-----------------------------")
#endif
      
      guard
         response.status == .ok
      else {
         throw(Abort(response.status, reason: "Refresh Token could not be exhanged for an Access Token."))
      }
      
      // Unwrap response
      let token: OAuth_RefreshTokenResponse = try response.content.decode(OAuth_RefreshTokenResponse.self)
      
#if DEBUG
      print("\n-----------------------------")
      print("Controller() \(#function)")
      print("-----------------------------")
      print("-----------------------------")
      print("Unwrapped: \(token)")
      print("-----------------------------")
#endif
      
      
      // Return view and update cookie 'access_token'
      let view = try await request.view.render(
         "protected-page"
      )
      
      let res = try await view.encodeResponse(for: request)
      res.cookies["access_token"] = createCookie(value: token.access_token, for: .AccessToken)
      return res
      
   }
   
}
