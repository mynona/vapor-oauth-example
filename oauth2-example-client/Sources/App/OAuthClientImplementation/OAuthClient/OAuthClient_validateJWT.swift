import Vapor
import JWTKit

extension OAuthClient {

   /// Verify JWT Signature and payload
   ///
   /// - Returns: true if signature and payload of all provided tokens succeeded
   /// - Throws: [OAuthClientErrors](x-source-tag://OAuthClientErrors)
   ///
   static func validateJWT(
      forTokens tokenSet: [TokenType:String],
      _ request: Request
   ) async throws -> Bool {

#if DEBUG
      print("\n-----------------------------")
      print("OAuthClient() \(#function)")
      print("-----------------------------")
      print("Called for \(tokenSet)")
      print("-----------------------------")
#endif
      
      // Retrieve JWK Set containing public RSA keys
      let response: ClientResponse
      do {
         response = try await request.client.get(
            "\(oAuthProvider)/.well-known/jwks.json"
         )
      } catch {
         throw OAuthClientErrors.openIDProviderServerError
      }

      guard
         response.status == .ok
      else {
         throw OAuthClientErrors.openIDProviderResponseError(
            "\(response.status)"
         )
      }
      
      let jwkSet: JWKS
      do {
         jwkSet = try response.content.decode(JWKS.self)
      } catch {
         throw OAuthClientErrors.validationError(
            "JWK Set decoding failed."
         )
      }

      // Extract JWK for customized identifier
      guard
         let jwks = jwkSet.find(identifier: publicKeyName)?.first
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
               _ = try signers.verify(token, as: PayloadAccessToken.self)

            case .RefreshToken:
               _ = try signers.verify(token, as: PayloadRefreshToken.self)

            case .IDToken:
               let payload = try signers.verify(token, as: PayloadIDToken.self)
               
               // Check nonce value
               guard
                  payload.nonce == nonce
               else {
                  throw OAuthClientErrors.validationError(
                     "Nonce could not be validated."
                  )
               }

            }
         } catch {
            throw OAuthClientErrors.validationError(
               "JWT Signature and Payload check of \(type) failed."
            )
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

