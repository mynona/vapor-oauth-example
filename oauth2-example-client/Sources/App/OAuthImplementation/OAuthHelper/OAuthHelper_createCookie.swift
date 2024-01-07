import Vapor
import Leaf

extension OAuthHelper {

   /// Create cookie to persist token on relying party (client)
   ///
   static func createCookie(withValue value: String, forToken tokenType: TokenType) -> HTTPCookies.Value {

      let maxAge: Int
      let path: String?

      switch tokenType {

      case .AccessToken:
         maxAge = 60 * 2 // 2 minutes
         path = nil

      case .RefreshToken:
         maxAge = 60 * 60 * 24 * 30 // 30 days
         path = nil // "/refresh" in real world situation

      case .IDToken:
         maxAge = 60 * 10 // 10 minutes
         path = nil

      }

      return HTTPCookies.Value(
         string: value,
         expires: Date(timeIntervalSinceNow: TimeInterval(maxAge)),
         maxAge: maxAge,
         domain: nil,
         path: path,
         isSecure: false, // in real world case: true
         isHTTPOnly: true,
         sameSite: .lax
      )

   }
   
}
