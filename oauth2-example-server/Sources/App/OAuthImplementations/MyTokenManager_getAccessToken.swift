import Vapor
import VaporOAuth
import Fluent
import JWT

extension MyTokenManager {

   /// Get Access Token for the token introspection
   func getAccessToken(_ accessToken: String) async throws -> VaporOAuth.AccessToken? {

      // Client sends JWT
      let jwt = try app.jwt.signers.verify(accessToken, as: Payload.self)

      // Check in database if an Access Token with
      // the unique token identifier (jti) exists
      guard
         let accessToken = try await MyAccessToken.query(on: app.db)
            .filter(\.$tokenString == jwt.jti)
            .first()
      else {
         return nil
      }

      // Delete expired access tokens for this user
      if let id = accessToken.id {
         let expiredTokens = try await MyAccessToken
            .query(on: app.db)
            .filter(\.$userID == accessToken.userID)
            .filter(\.$expiryTime < accessToken.expiryTime)
            .filter(\.$id != id)
            .all()

#if DEBUG
         print("\n-----------------------------")
         print("MyTokenManager().getAccessToken()")
         print("-----------------------------")
         print("Count of expired tokens for this user: \(expiredTokens.count)")
         print("Those access tokens have been deleted.")
         print("-----------------------------")
#endif

         try await expiredTokens.delete(on: app.db)
      }


#if DEBUG
      print("\n-----------------------------")
      print("MyTokenManager().getAccessToken()")
      print("-----------------------------")
      print("Received access token: \(jwt)")
      print("-----------------------------")
      print("Database access token: \(accessToken)")
      print("-----------------------------")
#endif

      // Return token from the database
      return accessToken
   }


}
