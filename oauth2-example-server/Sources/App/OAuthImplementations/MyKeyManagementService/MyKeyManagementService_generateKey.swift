import Vapor
import VaporOAuth
import Fluent
import JWTKit

extension MyKeyManagementService {

   func generateKey() throws -> JWTKit.RSAKey {

#if DEBUG
      print("\n-----------------------------")
      print("MyKeyManagementService() \(#function)")
      print("-----------------------------")
      print("Called with parameters:")
      print("-----------------------------")
#endif

      guard
         let publicKey
      else {
         throw Abort(.internalServerError, reason: "Public RSA key could not be retrieved.")
      }

      return publicKey

   }

}
