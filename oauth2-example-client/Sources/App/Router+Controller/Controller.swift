import Vapor
import Leaf

struct Controller: Encodable {

   enum CookieType {
      case AccessToken
      case RefreshToken
      case TemporaryValues
   }

   /// Create cookie to store token value
   func createCookie(value: String, for cookieType: CookieType) -> HTTPCookies.Value {

      let maxAge: Int
      let path: String?

      switch cookieType {

      case .AccessToken:
         maxAge = 60 * 2 // 2 minutes
         path = nil

      case .RefreshToken:
         maxAge = 60 * 60 * 24 * 30 // 30 days
         path = nil // "/refresh" in real world situation

      case .TemporaryValues:
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
