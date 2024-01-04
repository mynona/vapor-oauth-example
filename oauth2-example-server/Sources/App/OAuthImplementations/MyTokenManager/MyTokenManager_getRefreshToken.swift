import Vapor
import VaporOAuth
import Fluent
import JWT

extension MyTokenManager {

   /// Get Refresh Token
   func getRefreshToken(_ refreshToken: String) async throws -> VaporOAuth.RefreshToken? {

      let token = try app.jwt.signers.verify(refreshToken, as: JWT_RefreshTokenPayload.self)

      guard
         let refreshToken = try await MyRefreshToken
            .query(on: app.db)
            .filter(\.$jti == token.jti)
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
            .filter(\.$exp < refreshToken.exp)
            .filter(\.$id != id)
            .all()

#if DEBUG
         print("\n-----------------------------")
         print("MyTokenManager() \(#function)")
         print("-----------------------------")
         print("Count of refresh tokens for this user: \(otherActiveRefreshTokens.count)")
         print("Those refresh tokens have been deleted")
         print("-----------------------------")
#endif

         try await otherActiveRefreshTokens.delete(on: app.db)

      }

      let payload = JWT_RefreshTokenPayload(
         jti: refreshToken.jti,
         clientID: refreshToken.clientID,
         userID: refreshToken.userID,
         scopes: refreshToken.scopes,
         exp: refreshToken.exp,
         issuer: "OpenID Provider",
         issuedAt: Date()
      )

      return payload

   }


}
