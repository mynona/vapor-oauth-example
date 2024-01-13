import Vapor

/// Send Request to /oauth/user-info/
/// - Parameters:
///   - token: The access token
public struct OAuthClient_TokenIntrospectionRequest: Content {

   public let token: String

   public init(
      token: String
   ) {
      self.token = token
   }
}
