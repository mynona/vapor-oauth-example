import Vapor
import VaporOAuth
import Fluent
import JWT

extension MyTokenManager {
   
   /// Update Refresh Token scope
   func updateRefreshToken(_ refreshToken: VaporOAuth.RefreshToken, scopes: [String]) async throws {

#if DEBUG
      print("\n-----------------------------")
      print("MyTokenManager() \(#function)")
      print("-----------------------------")
      print("Parameter: \(refreshToken)")
      print("-----------------------------")
#endif

      if let token = try await MyRefreshToken
         .query(on: app.db)
         .filter(\.$jti == refreshToken.jti)
         .first() {

         token.scopes = scopes

         try await token.save(on: app.db)

      }
   }

}
