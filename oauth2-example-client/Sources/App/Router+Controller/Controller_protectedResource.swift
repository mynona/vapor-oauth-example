import Vapor
import Leaf

extension Controller {

   func protectedResource(_ request: Request) async throws -> Response {

      // Check if the Access Token is valid

      guard
         let introspectionResult = try await OAuthClient.validateAccessToken(request),
         introspectionResult.tokenInfo.active == true
      else {
         return request.redirect(to: "http://localhost:8089/unauthorized")
      }

      // You might include to check here also if the scope is correct

#if DEBUG
      print("\n-----------------------------")
      print("Controller() \(#function)")
      print("-----------------------------")
      print("Check scopes")
      print("\(introspectionResult)")
      print("-----------------------------")
#endif


      // Return view and update cookies if renewed tokens have been returned
      let view = try await request.view.render(
         "protected-resource"
      )

      let response = try await view.encodeResponse(for: request)

      // Replace Access Token cookie if a new Access Token has been returned
      if let accessToken = introspectionResult.accessToken {
         response.cookies["access_token"] = OAuthClient.createCookie(
            withValue: accessToken,
            forToken: .AccessToken,
            environment: request.application.environment
         )
      }

      // Replace Refresh Token cookie if a new Refresh Token has been returned
      if let refreshToken = introspectionResult.refreshToken {
         response.cookies["refresh_token"] = OAuthClient.createCookie(
            withValue: refreshToken,
            forToken: .RefreshToken,
            environment: request.application.environment
         )
      }
      
      return response

   }

}
