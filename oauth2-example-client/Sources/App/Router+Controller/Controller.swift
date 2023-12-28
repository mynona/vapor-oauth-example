import Vapor
import JWT

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


   func validateJWT(forToken token: String, _ request: Request) async throws -> Bool {

#if DEBUG
      print("\n-----------------------------")
      print("validateJWT() \(#function)")
      print("-----------------------------")
      print("Called with Parameter:")
      print("\(token)")
      print("-----------------------------")
#endif

      let response = try await request.client.get("http://localhost:8090/.well-known/jwks.json")

      guard
         response.status == .ok
      else {
         throw Abort(.badRequest, reason: "JWK could not be retrieved from OpenID Provider.")
      }

      let jwks: OAuth_JWKResponse = try response.content.decode(OAuth_JWKResponse.self)

      // In this example only one key exists

      guard
         let firstKey = jwks.keys.first,
         let kid = firstKey.kid,
         let kty = firstKey.kty,
         let e = firstKey.e,
         let n = firstKey.n,
         let alg = firstKey.alg
      else {
         throw Abort(.badRequest, reason: "JWK key could not be unpacked")
      }

      let publicKey = JWTKit.RSAKey(modulus: n, exponent: e)

#if DEBUG
      print("\n-----------------------------")
      print("validateJWT() \(#function)")
      print("-----------------------------")
      print("RSAKey: \(publicKey)")
      print("-----------------------------")
#endif


      let signers = JWTSigners()
      signers.use(.rs256(key: publicKey!))

      // Validate JWT payload and correct signature
      // In this example we just validate the signature and use an empty payload

      // For a real world case check JWKKit to retrieve the jwks.json

      do {
         let payload = try signers.verify(token, as: EmptyPayload.self)
      } catch {
         // Signature or payload issue
         return false
      }
      return true


   }

}
