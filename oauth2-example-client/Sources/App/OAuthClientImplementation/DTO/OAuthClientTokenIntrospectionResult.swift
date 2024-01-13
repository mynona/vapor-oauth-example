import Vapor

public struct OAuthClient_TokenIntrospectionResult: Content {

   public let tokenInfo: OAuthClient_TokenIntrospectionResponse
   public let accessToken: String?
   public let refreshToken: String?

   public init(
      tokenInfo: OAuthClient_TokenIntrospectionResponse,
      accessToken: String?,
      refreshToken: String?
   ) {
      self.tokenInfo = tokenInfo
      self.accessToken = accessToken
      self.refreshToken = refreshToken
   }
}
