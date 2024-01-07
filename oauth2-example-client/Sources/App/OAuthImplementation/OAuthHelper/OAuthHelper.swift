import Vapor

/// Manages all OpenID Provider calls
/// 
public struct OAuthHelper: Content {

   /// URL of the OpenID Provider
   static let oAuthProvider: String = "http://localhost:8090"
   /// Relying party callback URL
   static let callback: String = "http://localhost:8089"
   /// State parameter
   static let stateVerifier: String = "\([UInt8].random(count: 32).hex)"
   /// PKCE CodeVerifier
   static let codeVerifier = "\([UInt8].random(count: 32).hex)"
   /// nonce Parameter stored in IDToken for validation
   static let nonce = "\([UInt8].random(count: 32).hex)"

}
