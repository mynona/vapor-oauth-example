import Vapor
import VaporOAuth
import Leaf
import Fluent
import JWTKit


/// Key Management Service
///
final class MyKeyManagementService: KeyManagementService {
   func generateKey() throws -> JWTKit.RSAKey {
      <#code#>
   }

   func storeKey(_ key: JWTKit.RSAKey) throws {
      <#code#>
   }

   func retrieveKey(identifier: String) throws -> JWTKit.RSAKey {
      <#code#>
   }

   func publicKeyIdentifier() throws -> String {
      <#code#>
   }

   func convertToJWK(_ key: JWTKit.RSAKey) throws -> JWTKit.JWK {
      <#code#>
   }


}
