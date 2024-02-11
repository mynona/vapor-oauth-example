import Vapor
import VaporOAuth
import Fluent
import JWTKit

extension MyKeyManagementService {

   func storeKey(_ key: JWTKit.RSAKey) throws {

#if DEBUG
      print("\n-----------------------------")
      print("MyKeyManagementService() \(#function)")
      print("-----------------------------")
      print("Called with parameters:")
      print("key: \(key)")
      print("-----------------------------")
#endif

   }

}
