import Vapor

public struct OAuthClientAuthorizationResponse: Content {

   enum CodingKeys: String, CodingKey {
      case expiryInMinutes = "expires_in"
      case accessToken = "access_token"
      case refreshToken = "refresh_token"
      case idToken = "id_token"
      case scope = "scope"
   }

   public let expiryInMinutes: Int
   public let accessToken: String?
   public let refreshToken: String?
   public let idToken: String?
   public let scope: String
   
   public init(
      expiryInMinutes: Int,
      accessToken: String?,
      refreshToken: String?,
      idToken: String?,
      scope: String
   ) {
      self.expiryInMinutes = expiryInMinutes
      self.accessToken = accessToken
      self.refreshToken = refreshToken
      self.idToken = idToken
      self.scope = scope
   }
   
}
