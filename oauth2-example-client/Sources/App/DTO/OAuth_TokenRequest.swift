import Vapor

public struct OAuth_TokenRequest: Content {

   // Authorization Code we exchange for a token
   public let code: String

   // Will always be "authorization_code"
   public let grant_type: String

   // Must be exactly the same uri as for the authorization code
   public let redirect_uri: String

   // Id that identifies the client application
   public let client_id: String

   // Secret for the client application for the oauth server
   public let client_secret: String

   public init(
      code: String,
      grant_type: String,
      redirect_uri: String,
      client_id: String,
      client_secret: String
   ) {
      self.code = code
      self.grant_type = grant_type
      self.redirect_uri = redirect_uri
      self.client_id = client_id
      self.client_secret = client_secret
   }
}
