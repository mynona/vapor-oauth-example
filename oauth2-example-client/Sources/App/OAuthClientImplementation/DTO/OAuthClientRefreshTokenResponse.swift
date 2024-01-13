import Vapor

/// Response from Open Id Provider
/// - Parameters:
///   - access_token: The access token 
///   - refresh_token: A refresh token
///   - id_token: The ID Token with user claims.
///   - expires_in: The lifetime of the access token, in seconds.
///   - token_type: Bearer is typically used unless an OpenID Provider has documented another type.
public struct OAuthClientRefreshTokenResponse: Content {

   // Access token
   public let access_token: String
   public let refresh_token: String?
   public let id_token: String?
   public let token_type: String
   public let expires_in: Int

   public init(
      access_token: String,
      refresh_token: String?,
      id_token: String?,
      token_type: String,
      expires_in: Int
   ) {
      self.access_token = access_token
      self.refresh_token = refresh_token
      self.id_token = id_token
      self.token_type = token_type
      self.expires_in = expires_in
   }
}
