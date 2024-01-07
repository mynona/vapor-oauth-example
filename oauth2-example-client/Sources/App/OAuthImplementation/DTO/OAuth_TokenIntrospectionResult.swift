import Vapor

public struct OAuth_TokenIntrospectionResult: Content {

   public let tokenInfo: OAuth_TokenIntrospectionResponse
   public let accessToken: String?
   public let refreshToken: String?

   public init(
      tokenInfo: OAuth_TokenIntrospectionResponse,
      accessToken: String?,
      refreshToken: String?
   ) {
      self.tokenInfo = tokenInfo
      self.accessToken = accessToken
      self.refreshToken = refreshToken
   }
}
