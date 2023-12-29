import Vapor
import JWT

struct Controller: Encodable {

   enum TokenType {
      case AccessToken
      case RefreshToken
      case IdToken
   }

   /// Create cookie to store token value
   func createCookie(value: String, for tokenType: TokenType) -> HTTPCookies.Value {

      let maxAge: Int
      let path: String?

      switch tokenType {

      case .AccessToken:
         maxAge = 60 * 2 // 2 minutes
         path = nil

      case .RefreshToken:
         maxAge = 60 * 60 * 24 * 30 // 30 days
         path = nil // "/refresh" in real world situation

      case .IdToken:
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


   func validateJWT(forToken token: String, tokenType: TokenType,  _ request: Request) async throws -> Bool {

#if DEBUG
      print("\n-----------------------------")
      print("validateJWT() \(#function)")
      print("-----------------------------")
      print("Called for \(tokenType)")
      print("-----------------------------")
#endif

      let response = try await request.client.get("http://localhost:8090/.well-known/jwks.json")

      guard
         response.status == .ok
      else {
         throw Abort(.badRequest, reason: "JWKS could not be retrieved from OpenID Provider.")
      }

      let jwkSet = try response.content.decode(JWKS.self)

      guard
         let jwks = jwkSet.find(identifier: JWKIdentifier(string: "public-key"))?.first,
         let modulus = jwks.modulus,
         let exponent = jwks.exponent,
         let publicKey = JWTKit.RSAKey(modulus: modulus, exponent: exponent)
      else {
         throw Abort(.badRequest, reason: "JWK key could not be unpacked")
      }

      let signers = JWTKit.JWTSigners()
      signers.use(.rs256(key: publicKey))


      // Validate JWT payload and correct signature
      // In this example we just validate the signature and use an empty payload

      var payload: EmptyPayload? = nil

      do {
         switch tokenType {
         case .AccessToken:
            let payload = try signers.verify(token, as: JWT_AccessTokenPayload.self)
         case .RefreshToken:
            let payload = try signers.verify(token, as: EmptyPayload.self)
         case .IdToken:
            let payload = try signers.verify(token, as: EmptyPayload.self)
         }
      } catch {
         // Signature or payload issue
         return false
      }

#if DEBUG
      print("\n-----------------------------")
      print("validateJWT() \(#function)")
      print("-----------------------------")
      print("Public Key: \(publicKey)")
      print("Payload: \(payload)")
      print("JWT Token validation was successful.")
      print("-----------------------------")
#endif

      return true


   }

}
