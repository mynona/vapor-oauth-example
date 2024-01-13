import Vapor
import JWTKit

extension OAuthClient {

   /// Verify JWT Signature and payload
   ///
   /// - Throws: verifyJWTError
   ///
   static func validateJWT(forTokens tokenSet: [TokenType:String], _ request: Request) async throws -> Bool {

#if DEBUG
      print("\n-----------------------------")
      print("OAuthClient() \(#function)")
      print("-----------------------------")
      print("Called for \(tokenSet)")
      print("-----------------------------")
#endif
      
      // Retrieve JWK Set with public RSA keys
      let response = try await request.client.get(
         "\(oAuthProvider)/.well-known/jwks.json"
      )
      
      guard
         response.status == .ok
      else {
         throw OAuthClientErrors.openIDProviderError(response.status)
      }
      
      let jwkSet: JWKS
      do {
         jwkSet = try response.content.decode(JWKS.self)
      } catch {
         throw OAuthClientErrors.validationError("JWK Set decoding failed.")
      }

      // Your customized identifier for the RSA key
      let kid = JWKIdentifier(string: "public-key")

      // Extract JWK for customized identifier
      guard
         let jwks = jwkSet.find(identifier: kid)?.first
      else {
         throw OAuthClientErrors.jwkKeyNotFound
      }

      // Generate public Key from JWT for valiation
      guard
         let modulus = jwks.modulus,
         let exponent = jwks.exponent,
         let publicKey = JWTKit.RSAKey(modulus: modulus, exponent: exponent)
      else {
         throw OAuthClientErrors.publicKeyGenerationFailed
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
               let payload = try signers.verify(token, as: Payload_IDToken.self)
               
               // Check nonce value
               guard
                  payload.nonce == nonce
               else {
                  throw OAuthClientErrors.validationError("Nonce could not be validated.")
               }

            }
         } catch {
            throw OAuthClientErrors.validationError("JWT Signature and Payload check of \(type) failed.")
         }

#if DEBUG
      print("\n-----------------------------")
      print("OAuthClient() \(#function)")
      print("-----------------------------")
      print("Signature and payload validation of \(type) was successful.")
      print("-----------------------------")
#endif

      }

      return true
      
   }
   
}
