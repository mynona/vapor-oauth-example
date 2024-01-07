import Vapor


/// Request id_token via /oauth/token
/// - Parameters:
///   - grant_type: "authorization_code" in case of the Authorization Code Flow
///   - client_id: The client ID for the relying party application, obtained when it registered with the OpenID Provider (authorization server)
///   - client_secret: Secret for the client application for the oauth server
///   
public struct OAuth_IDTokenRequest: Content {

   public let grant_type: String
   public let client_id: String
   public let client_secret: String
   public let nonce: String

   public init(
      grant_type: String,
      client_id: String,
      client_secret: String,
      nonce: String
   ) {
      self.grant_type = grant_type
      self.client_id = client_id
      self.client_secret = client_secret
      self.nonce = nonce
   }
}
