import Vapor
import JWTKit

extension Controller {

   /// verifyJWT Error Codes
   ///
   /// - openIDProviderError: Non 200 response from the OpenID Provider
   /// - jwksDecodingError: JWK Set could not be decoded
   /// - jwtValidationError: Token signature or payload validation failed
   ///
   enum verifyJWTError: Error {
      case openIDProviderError
      case jwksDecodingError
      case jwtValidationError
   }


   /// Verify JWT Signature and payload
   ///
   /// - Throws: verifyJWTError
   ///
   func verifyJWT(forTokens tokenSet: [TokenType:String], _ request: Request) async throws -> Bool {

#if DEBUG
      print("\n-----------------------------")
      print("validateJWT() \(#function)")
      print("-----------------------------")
      print("Called for \(tokenSet)")
      print("-----------------------------")
#endif
      
      // Retrieve JWK Set with public RSA keys
      let response = try await request.client.get(
         "http://localhost:8090/.well-known/jwks.json"
      )
      
      guard
         response.status == .ok
      else {
         throw verifyJWTError.openIDProviderError
      }
      
      let jwkSet: JWKS
      do {
         jwkSet = try response.content.decode(JWKS.self)
      } catch {
         throw verifyJWTError.jwksDecodingError
      }

      // Your customized identifier for the RSA key
      let kid = JWKIdentifier(string: "public-key")

      guard
         let jwks = jwkSet.find(identifier: kid)?.first,
         let modulus = jwks.modulus,
         let exponent = jwks.exponent,
         let publicKey = JWTKit.RSAKey(modulus: modulus, exponent: exponent)
      else {
         throw verifyJWTError.jwksDecodingError
      }
      
      let signers = JWTKit.JWTSigners()
      signers.use(.rs256(key: publicKey))

      // Validate JWT Signature and payload
      for (type, token) in tokenSet {

         do {

            switch type {

            case .AccessToken:
               _ = try signers.verify(token, as: Payload_AccessToken.self)

            case .RefreshToken:
               _ = try signers.verify(token, as: Payload_RefreshToken.self)

            case .IDToken:
               _ = try signers.verify(token, as: Payload_IDToken.self)

            }
         } catch { throw verifyJWTError.jwtValidationError }

#if DEBUG
      print("\n-----------------------------")
      print("validateJWT() \(#function)")
      print("-----------------------------")
      print("Signature and payload validation of \(type) was successful.")
      print("-----------------------------")
#endif

      }

      return true
      
   }
   
}
