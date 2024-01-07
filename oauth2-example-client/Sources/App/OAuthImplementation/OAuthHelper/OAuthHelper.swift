import Vapor

/// Manages all OpenID Provider calls
/// 
public struct OAuthHelper: Content {

   /// URL of the OpenID Provider
   static let oAuthProvider: String = "http://localhost:8090"
   /// PKCE CodeVerifier
   static let codeVerifier = "hello_world" // [UInt8].random(count: 128).hex
   /// nonce Parameter stored in IDToken for validation
   static let nonce = "nonce-test"

}
