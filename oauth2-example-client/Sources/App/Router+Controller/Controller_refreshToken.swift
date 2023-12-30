import Vapor
import Leaf

extension Controller {
   
   /// Obtain a new refresh_token from the Open ID provider
   ///
   /// Endpoint /oauth/token is called with Basic Authentication 
   ///
   func refreshToken(_ request: Request) async throws -> Response {

      guard
         let cookie = request.cookies["refresh_token"]?.string
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

      guard
      let newAccessToken = try await requestNewAccessToken(forRefreshToken: cookie, request)
      else {
         throw Abort(.badRequest, reason: "Refresh token could not be exchanged for an access token.")
      }

      // Return view and update cookie 'access_token'
      let view = try await request.view.render(
         "introspection-success"
      )

      let res = try await view.encodeResponse(for: request)
      res.cookies["access_token"] = createCookie(value: newAccessToken.access_token, for: .AccessToken)
      return res

   }
   
}
