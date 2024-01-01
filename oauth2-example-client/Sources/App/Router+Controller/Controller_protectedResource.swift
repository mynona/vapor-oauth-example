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

      var result = try await introspect(request)
      // If access_token is not valid anymore, try to request a new access_token with the refresh_token
      if result?.introspection?.active == false {
         result = try await introspect(enforceNewAccessToken: true, request)
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

      // Return view and update cookie 'access_token'
      let view = try await request.view.render(
         "protected-resource"
      )

      let res = try await view.encodeResponse(for: request)
      res.cookies["access_token"] = createCookie(value: access_token, for: .AccessToken)
      return res

   }

}
