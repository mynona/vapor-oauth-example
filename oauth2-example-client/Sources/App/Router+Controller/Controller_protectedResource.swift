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

      var result = try await verifyAccessToken(request)
      // If access_token is not valid anymore, try to request a new access_token with the refresh_token
      if result?.introspection?.active == false {
         result = try await verifyAccessToken(enforceNewAccessToken: true, request)
      }

      // Run introspection
      guard
         let introspection = result?.introspection,
         let access_token = result?.accessToken,
         introspection.active == true
      else { //

         let view = try await request.view.render(
            "unauthorized"
         )
         let res = try await view.encodeResponse(for: request)
         return res

      }

      // Here you would also check if the user has the correct scope to access this resource:

#if DEBUG
      print("\n-----------------------------")
      print("Controller() \(#function)")
      print("-----------------------------")
      print("Check scopes")
      print("Scopes: \(introspection.scope)")
      print("-----------------------------")
#endif


      // Return view and update cookie 'access_token'
      let view = try await request.view.render(
         "protected-resource"
      )

      let res = try await view.encodeResponse(for: request)
      res.cookies["access_token"] = createCookie(withValue: access_token, forToken: .AccessToken)
      // Replace refresh_token cookie if a new refresh_token has been returned
      if let refresh_token = result?.refreshToken {
         res.cookies["refresh_token"] = createCookie(withValue: refresh_token, forToken: .RefreshToken)
      }
      return res

   }

}
