import Vapor

/// Send Request to /oauth/user-info/
/// - Parameters:
///   - token: The access token
public struct OAuthClientTokenIntrospectionRequest: Content {

   public let token: String

   public init(
      token: String
   ) {
      self.token = token
   }
}
