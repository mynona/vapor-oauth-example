import Vapor
import JWTKit

extension OAuthHelper {

   public enum ValidateJWTError: Error {

      /// OpenID Provider response status was not 200 OK
      case openIDProviderError
      /// Retrieved JWK Set decoding failed
      case jwkSetDecodingError
      /// JWK for provided key identifier (kid) was not found
      case jwkMissing
      /// JWK decoding failed
      case jwkDecodingError
      /// Verification of token signature or payload failed
      case jwtValidationError

   }


   /// Verify JWT Signature and payload
   ///
   /// - Throws: verifyJWTError
   ///
   static func validateJWT(forTokens tokenSet: [TokenType:String], _ request: Request) async throws -> Bool {

#if DEBUG
      print("\n-----------------------------")
      print("validateJWT() \(#function)")
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
         throw ValidateJWTError.openIDProviderError
      }
      
      let jwkSet: JWKS
      do {
         jwkSet = try response.content.decode(JWKS.self)
      } catch {
         throw ValidateJWTError.jwkSetDecodingError
      }

      // Your customized identifier for the RSA key
      let kid = JWKIdentifier(string: "public-key")

      // Extract JWK for customized identifier
      guard
         let jwks = jwkSet.find(identifier: kid)?.first
      else {
         throw ValidateJWTError.jwkMissing
      }

      // Generate public Key from JWT for valiation
      guard
         let modulus = jwks.modulus,
         let exponent = jwks.exponent,
         let publicKey = JWTKit.RSAKey(modulus: modulus, exponent: exponent)
      else {
         throw ValidateJWTError.jwkDecodingError
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
         } catch {
            throw ValidateJWTError.jwtValidationError
         }

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
