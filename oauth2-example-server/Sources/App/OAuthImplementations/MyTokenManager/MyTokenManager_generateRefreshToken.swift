import Vapor
import VaporOAuth
import Fluent
import JWT

extension MyTokenManager {
   
   func generateRefreshToken(clientID: String, userID: String?, scopes: [String]?) async throws -> VaporOAuth.RefreshToken {

      let entitlements = try await isUserEntitled(user: userID, scopes: scopes)

      guard
         entitlements.entitled == true
      else {
         throw Abort(.unauthorized, reason: "User is not entitled for this scope.")
      }

      let refreshToken = try createRefreshToken(
         clientID: clientID,
         userID: userID,
         scopes: entitlements.scopes
      )
      
      try await refreshToken.save(on: app.db)

      let payload = JWT_RefreshTokenPayload(
         jti: refreshToken.jti,
         clientID: refreshToken.clientID,
         userID: refreshToken.userID,
         scopes: refreshToken.scopes,
         exp: refreshToken.exp,
         issuer: "OpenID Provider",
         issuedAt: Date()
      )

      //return payload
      return refreshToken
   }
   
}
