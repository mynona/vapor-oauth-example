import Vapor
import VaporOAuth
import Fluent
import JWT

extension MyTokenManager {
   
   func generateRefreshToken(clientID: String, userID: String?, scopes: [String]?) async throws -> VaporOAuth.RefreshToken {

      guard
         try await isUserEntitled(user: userID, scopes: scopes) == true
      else {
         throw Abort(.unauthorized, reason: "User is not entitled for this scope.")
      }

      let refreshToken = try createRefreshToken(
         clientID: clientID,
         userID: userID,
         scopes: scopes
      )
      
      try await refreshToken.save(on: app.db)

      let payload = JWT_RefreshTokenPayload(
         tokenString: refreshToken.tokenString,
         clientID: refreshToken.clientID,
         userID: refreshToken.userID,
         scopes: refreshToken.scopes,
         expiration: refreshToken.expiration,
         issuer: "OpenID Provider",
         issuedAt: Date()
      )

      return refreshToken
   }
   
}
