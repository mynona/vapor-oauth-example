import Vapor
import VaporOAuth
import Fluent
import JWTKit

/// Manage Token handling
///
/// * generate access_token, refresh_token, id_token
/// * retrieve tokens
/// * update tokens
/// 
final class MyTokenManager: TokenManager {

   let app: Application
   let keyManagementService: KeyManagementService


   // ----------------------------------------------------------
   
   init(app: Application) {
      self.app = app
      self.keyManagementService = MyKeyManagementService(app: app)
   }

   // ----------------------------------------------------------
   
   /// Create Access Token
   func createAccessToken(tokenString: String, clientID: String, userID: String?, scopes: [String]?, expiryTime: Date) throws -> MyAccessToken {
      
      return MyAccessToken(
         tokenString: tokenString,
         clientID: clientID,
         userID: userID,
         scopes: scopes,
         expiryTime: expiryTime
      )
      
   }
   
   // ----------------------------------------------------------
   
   /// Create Refresh Token
   func createRefreshToken(clientID: String, userID: String?, scopes: [String]?) throws -> MyRefreshToken {
      
      // Expiry time: 30 days
      let expiryTimeRefreshToken = Date(timeIntervalSinceNow: TimeInterval(60 * 60 * 24 * 30))
      
      return MyRefreshToken(
         jti: [UInt8].random(count: 32).hex,
         clientID: clientID,
         userID: userID,
         scopes: scopes,
         exp: expiryTimeRefreshToken
      )
      
   }
   
   // ----------------------------------------------------------
   
   /// Create IDToken
   func createIDToken(subject: String, audience: [String], nonce: String?, authTime: Date?) throws -> MyIDToken {
      
      // Expiry time: 30 days
      let expiryTimeIDToken = Date(timeIntervalSinceNow: TimeInterval(60 * 60 * 24 * 30))
      
      return MyIDToken(
         jti: [UInt8].random(count: 32).hex,
         iss: "OpenID Provider",
         sub: subject,
         aud: audience,
         exp: expiryTimeIDToken,
         iat: Date(),
         nonce: nonce,
         authTime: nil
      )
      
   }

   // ----------------------------------------------------------

   func isUserEntitled(user userID: String?, scopes: [String]?) async throws -> (entitled: Bool, scopes: [String]) {

      // Get user
      guard
         let userID,
         let uuid = UUID(uuidString: userID),
         let scopes,
         scopes.count > 0,
         let author = try await MyUser
            .query(on: app.db)
            .filter(\.$id == uuid)
            .first()
      else {
         throw Abort(.badRequest, reason: "No user specified or no scopes requested.")
      }

      // Get unique sets of all scopes
      let userScopes = Set(author.roles)
      let requestedScopes = Set(scopes)

#if DEBUG
      print("\n-----------------------------")
      print("MyTokenManager() \(#function)")
      print("-----------------------------")
      print("Requested scopes: \(requestedScopes)")
      print("User entitled for: \(userScopes)")
      print("-----------------------------")
#endif

      // Return true if all requestedScopes are part of the user scopes
      let entitled =  requestedScopes.isSubset(of: userScopes)

      return (entitled: entitled, scopes: Array(userScopes))

   }

}
