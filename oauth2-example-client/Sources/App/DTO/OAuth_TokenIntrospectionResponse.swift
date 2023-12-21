import Vapor

public struct OAuth_TokenIntrospectionResponse: Content {

   // Only the active claim is guaranteed to be included.
   // All other claims are optional and may not be provided
   // by an oauth provider
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
