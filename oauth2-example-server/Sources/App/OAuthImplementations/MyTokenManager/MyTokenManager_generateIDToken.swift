import Vapor
import VaporOAuth
import Fluent
import JWTKit

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

      let entitlements = try await isUserEntitled(user: userID, scopes: scopes)

      guard
         entitlements.entitled == true
      else {
         throw Abort(.unauthorized, reason: "User is not entitled for this scope.")
      }

      var subject: String = ""
      var authTime: Date =  Date()
      if let uuid = UUID(uuidString: userID) {

         // Query database for user
         if let author = try await MyUser
            .query(on: app.db)
            .filter(\.$id == uuid)
            .first() {

            if let id = author.id {
               subject = "\(id)"
            }

            if let created_at = author.createdAt {
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

      // Delete expired id_tokens for this user
      if let id = idToken.id {
         let expiredTokens = try await MyIDToken
            .query(on: app.db)
            .filter(\.$exp < idToken.exp)
            .filter(\.$id != id)
            .all()
         
         try await expiredTokens.delete(on: app.db)
         
      }

      let payload = JWT_IDTokenPayload(
         sub: idToken.sub,
         aud: idToken.aud,
         exp: idToken.exp,
         nonce: idToken.nonce,
         authTime: idToken.authTime,
         iss: idToken.iss,
         iat: idToken.iat,
         jti: idToken.jti
      )

      return payload

   }

}



