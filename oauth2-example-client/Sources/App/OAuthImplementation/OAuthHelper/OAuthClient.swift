import Vapor

/// Manages all OpenID Provider calls
/// 
public struct OAuthClient: Content {

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
   /// Cookie duration Access Token
   static let maxAgeAccessToken: Int = 60 * 2
   /// Cookie duration Refresh Token
   static let maxAgeRefreshToken: Int = 60 * 60 * 24 * 30
   /// Cookie duration ID Token
   static let maxAgeIDToken: Int = 60 * 60

}

public enum OAuthClientErrors: Error {

   /// Request did not have any `access_token` cookie.
   case noAccessTokenCookieFound
   /// OpenID Provider could not be reached
   case openIDProviderNoResponse
   /// OpenID Provider response status was not 200 OK
   case openIDProviderError(HTTPStatus)
   /// Data could not be decoded
   case DataDecodingError

}
