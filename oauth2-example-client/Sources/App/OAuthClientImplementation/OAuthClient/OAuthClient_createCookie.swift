import Vapor
import Leaf

extension OAuthClient {

   /// Create cookie to persist token on relying party (client)
   ///
   /// - Parameters:
   ///   - withValue: Cookie string value
   ///   - forToken: TokenType
   ///   - environment: Environment
   ///
   /// - Returns: A single cookie (key/value pair)
   ///
   static func createCookie(
      withValue value: String,
      forToken tokenType: TokenType,
      environment: Environment
   ) -> HTTPCookies.Value {

      let maxAge: Int
      let path: String?

      switch tokenType {

      case .AccessToken:
         maxAge = maxAgeAccessToken
         path = nil

      case .RefreshToken:
         maxAge = maxAgeRefreshToken
         path = nil

      case .IDToken:
         maxAge = maxAgeIDToken
         path = nil

      }

      let isSecure = if environment == .production { true } else { false }

      return HTTPCookies.Value(
         string: value,
         expires: Date(timeIntervalSinceNow: TimeInterval(maxAge)),
         maxAge: maxAge,
         domain: nil,
         path: path,
         isSecure: isSecure,
         isHTTPOnly: true,
         sameSite: .lax
      )

   }

}
