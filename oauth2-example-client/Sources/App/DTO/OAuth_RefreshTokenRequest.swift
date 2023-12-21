import Vapor

public struct OAuth_RefreshTokenRequest: Content {

   // Will always be "authorization_code"
   public let grant_type: String

   // Id that identifies the client application
   public let client_id: String

   // Secret for the client application for the oauth server
   public let client_secret: String

   // Refresh token
   public let refresh_token: String

   public init(
      grant_type: String,
      client_id: String,
      client_secret: String,
      refresh_token: String
   ) {
      self.grant_type = grant_type
      self.client_id = client_id
      self.client_secret = client_secret
      self.refresh_token = refresh_token
   }
}
