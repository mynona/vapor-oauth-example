import Vapor
import VaporOAuth
import Fluent
import JWT

extension MyTokenManager {

   func generateIDToken(clientID: String, userID: String, scopes: [String]?, expiryTime: Int, nonce: String?) async throws -> VaporOAuth.IDToken {

#if DEBUG
      print("\n-----------------------------")
      print("MyTokenManager() \(#function)")
      print("-----------------------------")
      print("Parameters:")
      print("clientID: \(clientID)")
      print("userID: \(userID)")
      print("scopes: \(scopes)")
      print("expiryTime: \(expiryTime)")
      print("nonce: \(nonce)")
      print("-----------------------------")
#endif

      var subject: String = ""
      var authTime: Date =  Date()
      if let uuid = UUID(uuidString: userID) {

         // Query database for user
         if let author = try await Author
            .query(on: app.db)
            .filter(\.$id == uuid)
            .first() {

            if let id = author.id {
               subject = "\(id)"
            }

            if let created_at = author.created_at {
               authTime = created_at
            }

         }
      }

      let idToken = try createIDToken(
         subject: subject,
         audience: ["\(clientID)"],
         nonce: nonce,
         authTime: authTime
      )

      try await idToken.save(on: app.db)

      return idToken

   }


}



