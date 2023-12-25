import Vapor
import VaporOAuth
import Fluent
import JWT

extension MyTokenManager {
   
   func generateRefreshToken(clientID: String, userID: String?, scopes: [String]?) async throws -> VaporOAuth.RefreshToken {

      let refreshToken = try createRefreshToken(
         clientID: clientID,
         userID: userID,
         scopes: scopes
      )
      
      try await refreshToken.save(on: app.db)
      
      return refreshToken
   }
   
}