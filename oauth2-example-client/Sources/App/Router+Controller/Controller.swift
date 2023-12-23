import Vapor
import Leaf

struct Controller: Encodable {

   enum CookieType {
      case AccessToken
      case RefreshToken
   }

   /// Create cookie to store token value
   func createCookie(token: String, for cookieType: CookieType) -> HTTPCookies.Value {

      let maxAge: Int
      let path: String?

      switch cookieType {

      case .AccessToken:
         maxAge = 60 * 2 // 2 minutes
         path = nil

      case .RefreshToken:
         maxAge = 60 * 60 * 24 * 30 // 30 days
         path = nil // "/refresh" in real world situation

      }

      return HTTPCookies.Value(
         string: token,
         expires: Date(timeIntervalSinceNow: TimeInterval(maxAge)),
         maxAge: maxAge,
         domain: nil,
         path: path,
         isSecure: false, // in real world case: true
         isHTTPOnly: true,
         sameSite: nil
      )

   }

}
