import Vapor
import VaporOAuth

/// JWT Signer Service
class MyJWTSignerService: VaporOAuth.JWTSignerService {
   
   let keyManagementService: VaporOAuth.KeyManagementService
   
   init(
      keyManagementService: VaporOAuth.KeyManagementService
   ) {
      self.keyManagementService = keyManagementService
   }
   
}
