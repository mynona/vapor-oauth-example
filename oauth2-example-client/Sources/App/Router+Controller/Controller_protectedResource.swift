import Vapor
import Leaf

extension Controller {

   func protectedResource(_ request: Request) async throws -> Response {

      // Check if Access Token has not expired
      // In case of an expired Access Token try to create a new Access Token with the Refresh Token
      // If this fails, redirect to 'unauthorized'

      guard
         let introspection = try await OAuthClient.validateAccessToken(request),
         introspection.tokenInfo.active == true
      else {
         return request.redirect(to: "http://localhost:8089/unauthorized")
      }

#if DEBUG
      print("\n-----------------------------")
      print("Controller() \(#function)")
      print("-----------------------------")
      print("Introspection:")
      print("\(introspection)")
      print("-----------------------------")
#endif

      // Check scopes for this page:

      guard
         let scopes = introspection.tokenInfo.scope,
         OAuthClient.validateScope(
            requiredScopes: "openid",
            retrievedScopes: scopes
         )
      else {
         throw OAuthClientErrors.scopesInvalid
      }

      // Return view and update cookies if renewed tokens have been returned
      let view = try await request.view.render(
         "protected-resource"
      )

      let response = try await view.encodeResponse(for: request)

      // Replace Access Token cookie if a new Access Token has been returned
      if let accessToken = introspection.accessToken {
         response.cookies["access_token"] = OAuthClient.createCookie(
            withValue: accessToken,
            forToken: .AccessToken,
            environment: request.application.environment
         )
      }

      // Replace Refresh Token cookie if a new Refresh Token has been returned
      if let refreshToken = introspection.refreshToken {
         response.cookies["refresh_token"] = OAuthClient.createCookie(
            withValue: refreshToken,
            forToken: .RefreshToken,
            environment: request.application.environment
         )
      }
      
      return response

   }

}
