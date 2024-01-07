import Vapor
import Leaf

extension Controller {

   /// Token introspection flow when accessing a protected resource
   ///
   /// Endpoint /oauth/token is called with Basic Authentication to check if the access_token is valid
   /// - valid: show page
   /// - invalid: show unauthorized page
   ///
   func protectedResource(_ request: Request) async throws -> Response {

      guard
         let introspectionResult = try await OAuthHelper.validateAccessToken(request),
         introspectionResult.tokenInfo.active == true
      else {
         let view = try await request.view.render(
            "unauthorized"
         )
         let res = try await view.encodeResponse(for: request)
         return res
      }

#if DEBUG
      print("\n-----------------------------")
      print("Controller() \(#function)")
      print("-----------------------------")
      print("Check scopes")
      print("\(introspectionResult)")
      print("-----------------------------")
#endif


      // Return view and update cookie 'access_token'
      let view = try await request.view.render(
         "protected-resource"
      )

      let res = try await view.encodeResponse(for: request)

      // Replace Access Token cookie if the Access Token is renewed
      if let accessToken = introspectionResult.accessToken {
         res.cookies["access_token"] = createCookie(withValue: accessToken, forToken: .AccessToken)
      }

      // Replace Refresh Token cookie if the Refresh Token is renewed
      if let refreshToken = introspectionResult.refreshToken {
         res.cookies["refresh_token"] = createCookie(withValue: refreshToken, forToken: .RefreshToken)
      }
      
      return res

   }

}
