import Vapor
import VaporOAuth
import Fluent
import JWTKit

extension MyKeyManagementService {

   /// Create a JWK from the public key
   ///
   /// Endpoint: /.well-known/jwks.json
   ///
   func convertToJWK(_ key: JWTKit.RSAKey) throws -> JWTKit.JWK {

#if DEBUG
      print("\n-----------------------------")
      print("MyKeyManagementService() \(#function)")
      print("-----------------------------")
      print("Called with parameters:")
      print("key: \(key)")
      print("-----------------------------")
#endif

      // (Key ID) Parameter for JWT JOSE Header
      let identifier = try publicKeyIdentifier()
      
      let jwkIdentifier = JWKIdentifier(string: identifier)
      return JWK.rsa(.rs256, identifier: jwkIdentifier, modulus: modulus, exponent: exponent)

   }

}
