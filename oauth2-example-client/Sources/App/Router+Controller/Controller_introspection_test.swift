import Vapor
import Leaf

extension Controller {

   /// Token introspection flow when accessing a protected resource
   ///
   /// Endpoint /oauth/token is called with Basic Authentication to check if the access_token is valid
   /// - valid: show page
   /// - invalid: show unauthorized page
   ///
   func introspectionExample(_ request: Request) async throws -> Response {

      var access_token: String? = request.cookies["access_token"]?.string

      // If access_token cookie doesn't exist try to request a new access_token
      if access_token == nil {

         let refresh_token = request.cookies["refresh_token"]?.string

         if let refresh_token {
            let response = try await requestNewAccessToken(forRefreshToken: refresh_token, request)
            if let accessToken = response?.access_token {
               access_token = accessToken
            }
         }
      }

      // Another way of doing it would be to have a long lived access_token cookie
      // and refresh the token if the introspection returns active=false

      guard
         let access_token
      else {
         // Unauthorized if no valid access token
         let view = try await request.view.render(
            "unauthorized"
         )
         let res = try await view.encodeResponse(for: request)
         return res
      }

      let introspection = try await token_info(accessToken: access_token, request)

      // Invalid access token
      guard
         let introspection,
         introspection.active == true
      else {
         let view = try await request.view.render(
            "unauthorized"
         )
         let res = try await view.encodeResponse(for: request)
         return res
      }

      // Return view and update cookie 'access_token'
      let view = try await request.view.render(
         "introspection-success"
      )

      let res = try await view.encodeResponse(for: request)
      res.cookies["access_token"] = createCookie(value: access_token, for: .AccessToken)
      return res

   }

}
