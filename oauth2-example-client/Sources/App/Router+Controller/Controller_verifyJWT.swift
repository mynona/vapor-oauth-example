import Vapor
import Leaf
import JWTKit

extension Controller {

   /// Verify JWT Signature and payload
   ///
   func verifyJWT(forToken token: String, tokenType: TokenType, _ request: Request) async throws -> Bool {

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
      var payload: JWTPayload? = nil

      do {
         switch tokenType {
         case .AccessToken:
            payload = try signers.verify(token, as: Payload_AccessToken.self)
         case .RefreshToken:
            payload = try signers.verify(token, as: Payload_RefreshToken.self)
         case .IDToken:
            payload = try signers.verify(token, as: Payload_IDToken.self)
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
      print("Signature and payload validation of \(tokenType) was successful.")
      print("-----------------------------")
#endif

      return true

   }

}
