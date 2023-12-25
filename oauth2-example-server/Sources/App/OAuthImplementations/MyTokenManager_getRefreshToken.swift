import Vapor
import VaporOAuth
import Fluent
import JWT

extension MyTokenManager {

   /// Get Refresh Token
   func getRefreshToken(_ refreshToken: String) async throws -> VaporOAuth.RefreshToken? {

      guard
         let refreshToken = try await MyRefreshToken
            .query(on: app.db)
            .filter(\.$tokenString == refreshToken)
            .first()
      else {
         return nil
      }

      // Important: vapor/oauth does not invalidate refresh tokens
      // Therefore, expired refresh tokens are only removed when a new
      // refresh token for this user has been issued. There is no
      // revoke feature.
      if let id = refreshToken.id {
         let otherActiveRefreshTokens = try await MyRefreshToken
            .query(on: app.db)
            .filter(\.$userID == refreshToken.userID)
            .filter(\.$expiryTime < refreshToken.expiryTime)
            .filter(\.$id != id)
            .all()

#if DEBUG
         print("\n-----------------------------")
         print("MyTokenManager().getRefreshToken()")
         print("-----------------------------")
         print("Count of refresh tokens for this user: \(otherActiveRefreshTokens.count)")
         print("Those refresh tokens have been deleted")
         print("-----------------------------")
#endif

         try await otherActiveRefreshTokens.delete(on: app.db)

      }

      return refreshToken

   }


}
