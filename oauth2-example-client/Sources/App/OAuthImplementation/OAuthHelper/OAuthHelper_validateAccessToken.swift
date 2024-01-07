import Vapor

extension OAuthHelper {

   /// Validate Access Token
   ///
   /// 1. Try to validate existing Access Token
   /// 2. If Access Token validation fails, try to exchange the Refresh Token for a new Access Token and validate new Access Token
   /// 3. Return tokenInfo result. In case a new Access and / or Refresh Token has / have been generated, return the new tokens as well
   ///
   static func validateAccessToken(_ request: Request) async throws -> OAuth_TokenIntrospectionResult? {

      var result = try await bla(request)
      // If access_token is not valid anymore, try to request a new access_token with the refresh_token
      if result?.tokenInfo.active == false {
         result = try await bla(enforceNewAccessToken: true, request)
      }

      guard
         let tokenInfo = result?.tokenInfo
      else {
         return nil // no valid access_token and no refresh_token
      }

      return OAuth_TokenIntrospectionResult(
         tokenInfo: tokenInfo,
         accessToken: result?.accessToken,
         refreshToken: result?.refreshToken
      )


   }



   /// Verify Access Token with oauth/token_info (introspection endpoint)
   ///
   /// - Parameters:
   ///   - enforceNewAccessToken: request new access_token regardless if an existing token was found or not
   ///
   static func bla(enforceNewAccessToken: Bool = false, _ request: Request) async throws -> OAuth_TokenIntrospectionResult? {

      // Get existing access_token from cookie
      var access_token: String? = request.cookies["access_token"]?.string
      var refresh_token: String? = request.cookies["refresh_token"]?.string

      // Request new access token if access_token cookie was not found OR
      // Enforce requesting a new access_token regardless of the cookie
      if access_token == nil || enforceNewAccessToken == true {

         do {
            let response = try await OAuthHelper.exchangeRefreshTokenForNewTokens(request)
            access_token = response.access_token
            refresh_token = response.refresh_token
         } catch  {
            return nil
         }

      }

      guard
         let access_token
      else {
         return nil
      }


      let introspection = try await OAuthHelper.validateWithIntrospectionEndpoint(accessToken: access_token, request)

      return OAuth_TokenIntrospectionResult(
         tokenInfo: introspection,
         accessToken: access_token,
         refreshToken: refresh_token
      )

   }

   
}
