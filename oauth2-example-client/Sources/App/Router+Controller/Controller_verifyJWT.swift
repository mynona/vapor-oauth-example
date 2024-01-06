import Vapor
import JWTKit

extension Controller {

   /// verifyJWT Error Codes
   ///
   /// - openIDProviderError: Non 200 response from the OpenID Provider
   /// - jwksDecodingError: JWK Set could not be decoded
   /// - payloadError: Token signature or payload validation failed
   ///
   enum verifyJWTError: Error {
      case openIDProviderError
      case jwksDecodingError
      case payloadError
   }


   /// Verify JWT Signature and payload
   ///
   /// - Throws: verifyJWTError
   ///
   func verifyJWT(forToken token: String, tokenType: TokenType, _ request: Request) async throws -> Bool {
      
#if DEBUG
      print("\n-----------------------------")
      print("validateJWT() \(#function)")
      print("-----------------------------")
      print("Called for \(tokenType)")
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
      
      guard
         let jwks = jwkSet.find(identifier: JWKIdentifier(string: "public-key"))?.first,
         let modulus = jwks.modulus,
         let exponent = jwks.exponent,
         let publicKey = JWTKit.RSAKey(modulus: modulus, exponent: exponent)
      else {
         throw verifyJWTError.jwksDecodingError
      }
      
      let signers = JWTKit.JWTSigners()
      signers.use(.rs256(key: publicKey))
      
      // Validate JWT Signature and payload
      switch tokenType {
         
      case .AccessToken:
         do { _ = try signers.verify(token, as: Payload_AccessToken.self) }
         catch { throw verifyJWTError.payloadError }

      case .RefreshToken:
         do { _ = try signers.verify(token, as: Payload_RefreshToken.self) }
         catch { throw verifyJWTError.payloadError }

      case .IDToken:
         do { _ = try signers.verify(token, as: Payload_IDToken.self) }
         catch { throw verifyJWTError.payloadError }
         
      }
      
#if DEBUG
      print("\n-----------------------------")
      print("validateJWT() \(#function)")
      print("-----------------------------")
      print("Public Key: \(publicKey)")
      print("Signature and payload validation of \(tokenType) was successful.")
      print("-----------------------------")
#endif
      
      return true
      
   }
   
}
