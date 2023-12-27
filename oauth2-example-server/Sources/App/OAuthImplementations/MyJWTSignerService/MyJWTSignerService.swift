import Vapor
import VaporOAuth
import Leaf
import Fluent

/// JWT Signer Service
final class MyJWTSignerService: JWTSignerService {

   var keyManagementService: VaporOAuth.KeyManagementService
   
   init(keyManagementService: VaporOAuth.KeyManagementService) {
      self.keyManagementService = keyManagementService
   }

}

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
