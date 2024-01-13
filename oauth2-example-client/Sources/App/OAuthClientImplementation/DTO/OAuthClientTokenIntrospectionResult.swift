import Vapor

public struct OAuthClientTokenIntrospectionResult: Content {

   public let tokenInfo: OAuthClientTokenIntrospectionResponse
   public let accessToken: String?
   public let refreshToken: String?

   public init(
      tokenInfo: OAuthClientTokenIntrospectionResponse,
      accessToken: String?,
      refreshToken: String?
   ) {
      self.tokenInfo = tokenInfo
      self.accessToken = accessToken
      self.refreshToken = refreshToken
   }
}
