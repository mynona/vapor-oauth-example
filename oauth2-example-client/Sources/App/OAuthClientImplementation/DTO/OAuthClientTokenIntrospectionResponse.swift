import Vapor

/// Open Id Provider response
/// - Parameters:
///   - active: true for an active access token. In case of false only the active parameters is returned
///   - exp: Expiration in seconds
///   - client_id: The client ID for the relying party application, obtained when it registered with the OpenID Provider (authorization server)
///   - username: Username of the user
///   - token_type: "bearer"
///
public struct OAuthClientTokenIntrospectionResponse: Content {

   public let active: Bool

   public let scope: String?
   public let exp: Int?
   public let client_id: String?
   public let username: String?
   public let token_type: String?

   public init(
      scope: String?,
      active: Bool,
      exp: Int?,
      client_id: String?,
      username: String?,
      token_type: String?
   ) {
      self.scope = scope
      self.active = active
      self.exp = exp
      self.client_id = client_id
      self.username = username
      self.token_type = token_type
   }
}
