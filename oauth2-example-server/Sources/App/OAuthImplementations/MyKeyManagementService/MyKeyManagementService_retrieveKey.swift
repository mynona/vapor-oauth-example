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

      if identifier == "public-key" {

         /*
         if let publicKey {
            return publicKey
         }
          */

         // ATTENTION: THERE IS A BUG IN THE CODE. The signing requests the public key but it actually nees the private key. Therefore this script returns the private key and the convertToJWK is hardcoded to return the public key at the moment until this problem is fixed.

         if let privateKey {
            return privateKey
         }


      }

      throw(Abort(.internalServerError, reason: "Private RSA Key could not be loaded."))
   }

}
