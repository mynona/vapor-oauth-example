import Vapor
import VaporOAuth
import Fluent
import JWTKit

extension MyKeyManagementService {


   func retrieveKey(identifier: String) throws -> JWTKit.RSAKey {

#if DEBUG
      print("\n-----------------------------")
      print("MyKeyManagementService() \(#function)")
      print("-----------------------------")
      print("Called with parameters:")
      print("identifier: \(identifier)")
      print("-----------------------------")
#endif


      if identifier == "private-key" {
         if let privateKey {
            return privateKey
         } else {
            throw Abort(.internalServerError, reason: "Private Key could not be retrieved.")
         }
      }

      if let publicKey {
         return publicKey
      } else {
         throw Abort(.internalServerError, reason: "Public Key could not be retrieved.")
      }


   }

}
