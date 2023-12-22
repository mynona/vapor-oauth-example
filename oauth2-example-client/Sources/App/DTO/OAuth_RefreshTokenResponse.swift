import Vapor

public struct OAuth_RefreshTokenResponse: Content {

   // Access token
   public let access_token: String

   // Token type
   public let token_type: String

   // Expiration in seconds
   public let expires_in: Int

   public init(
      access_token: String,
      token_type: String,
      expires_in: Int
   ) {
      self.access_token = access_token
      self.token_type = token_type
      self.expires_in = expires_in
   }
}
