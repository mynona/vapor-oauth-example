/// Helper for OpenID Provider calls
/// 
/// - Throws: [OAuthClientErrors](x-source-tag://OAuthClientErrors)
///
public struct OAuthClient {

   /// URL of the OpenID Provider
   static let oAuthProvider: String = "http://localhost:8090"

   /// Relying party callback URL
   static let callbackURL: String = "http://localhost:8089"

   /// State parameter
   static let stateVerifier: String = "\([UInt8].random(count: 32).hex)"

   /// PKCE CodeVerifier
   static let codeVerifier = "\([UInt8].random(count: 32).hex)"

   /// nonce Parameter stored in IDToken for validation
   static let nonce = "\([UInt8].random(count: 32).hex)"

   /// Cookie duration Access Token
   static let maxAgeAccessToken: Int = 60 * 2

   /// Cookie duration Refresh Token
   static let maxAgeRefreshToken: Int = 60 * 60 * 24 * 30

   /// Cookie duration ID Token
   static let maxAgeIDToken: Int = 60 * 60

   /// Server Session Cookie name
   static let serverSessionCookieName = "vapor-session"

   /// Customized Public RSA Key name for token validation
   static let publicKeyName = "public-key"

   /// Resource Server username for basic authentication
   static let resourceServerUsername = "resource-1"

   // Resource Server password for basic authentication
   static let resourceServerPassword = "resource-1-password"

   // Client ID to call token endpoint
   static let clientID = "1"

   // Client secret to call token endpoint
   static let clientSecret = "password123"

}
