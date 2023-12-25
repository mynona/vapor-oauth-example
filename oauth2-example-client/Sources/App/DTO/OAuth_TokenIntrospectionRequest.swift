import Vapor

/// Send Request to /oauth/user-info/
/// - Parameters:
///   - token: 
public struct OAuth_TokenIntrospectionRequest: Content {

   // Access Token that is sent to the token introspection endpoint
   // for validation
   public let token: String

   public init(
      token: String
   ) {
      self.token = token
   }
}
