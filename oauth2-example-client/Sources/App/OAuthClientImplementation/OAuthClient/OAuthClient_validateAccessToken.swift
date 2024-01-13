import Vapor

extension OAuthClient {
   
   /// Validate Access Token
   ///
   /// 1. Try to validate existing Access Token
   /// 2. If Access Token validation fails, try to exchange the Refresh Token for a new Access Token and validate new Access Token
   /// 3. Return tokenInfo result. In case a new Access and / or Refresh Token has / have been generated, return the new tokens as well
   ///
   /// - Returns
   ///   - `OAuthClientTokenIntrospectionResult`
   ///   - `nil` if no valid Access and / or Refresh Token existed
   ///
   static func validateAccessToken(
      _ request: Request
   ) async throws -> OAuthClientTokenIntrospectionResult? {
      
      /// Validate Access Token with introspection endpoint
      ///
      func validate(
         enforceNewAccessToken: Bool = false,
         _ request: Request
      ) async throws -> OAuthClientTokenIntrospectionResult? {
         
         // Get existing access_token from cookie
         var accessToken: String? = request.cookies["access_token"]?.string
         var refreshToken: String? = request.cookies["refresh_token"]?.string
         
         // If Access Token was not found
         // or retrieval of a new Access Token is enforced
         if accessToken == nil || enforceNewAccessToken == true {
            
            do {
               let response = try await OAuthClient.exchangeRefreshTokenForNewTokens(request)
               
               // Replace existing Tokens with newly retrieved Tokens
               accessToken = response.access_token
               if let newRefreshToken = response.refresh_token {
                  refreshToken = newRefreshToken
               }
            } catch  {
               return nil
            }
            
         }
         
         // Valid Access Token?
         guard
            let accessToken
         else {
            return nil
         }
         
         // Call introspection endpoint
         let tokenInfo: OAuthClientTokenIntrospectionResponse
         do {
            tokenInfo = try await OAuthClient.introspect(
               accessToken: accessToken,
               request
            )
         } catch {
            return nil
         }
         
         return OAuthClientTokenIntrospectionResult(
            tokenInfo: tokenInfo,
            accessToken: accessToken,
            refreshToken: refreshToken
         )
      }
      
      // Validate existing Access Token:
      // If validation fails, try to request a new Access Token
      // with the Refresh Token
      
      var validationResult = try await validate(request)
      // If Access Token validation fails, try to exchange the Refresh Token for a new Access token
      if validationResult?.tokenInfo.active == false {
         validationResult = try await validate(enforceNewAccessToken: true, request)
      }
      
      guard
         let tokenInfo = validationResult?.tokenInfo
      else {
         // No valid Access and Refresh Token
         return nil
      }
      
      return OAuthClientTokenIntrospectionResult(
         tokenInfo: tokenInfo,
         accessToken: validationResult?.accessToken,
         refreshToken: validationResult?.refreshToken
      )
      
   }
   
}

