import Vapor
import VaporOAuth
import Fluent
import JWT

/// Manage Token handling
///
/// * generate access_token, refresh_token, id_token
/// * retrieve tokens
/// * update tokens
/// 
final class MyTokenManager: TokenManager {

   let app: Application
   
   // ----------------------------------------------------------
   
   init(app: Application) {
      self.app = app
   }
   
   // ----------------------------------------------------------
   /*
   /// Create JWT that is returned to the client
   /// - Returns: signed JWT as String
   func createJWT(subject: String, expiration: Date, issuer: String, audience: String, jti: String, issuedAtTime: Date ) throws -> String {
      
      let payload = Payload(
         subject: SubjectClaim(value: subject),
         expiration: ExpirationClaim(value: expiration),
         issuer: issuer,
         audience: audience,
         jti: jti,
         issuedAtTime: issuedAtTime
      )
      
      return try app.jwt.signers.sign(payload)
      
   }
    */

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
         tokenString: [UInt8].random(count: 32).hex,
         clientID: clientID,
         userID: userID,
         scopes: scopes,
         expiration: expiryTimeRefreshToken
      )
      
   }
   
   // ----------------------------------------------------------
   
   /// Create IDToken
   func createIDToken(subject: String, audience: [String], nonce: String?, authTime: Date?) throws -> MyIDToken {
      
      // Expiry time: 30 days
      let expiryTimeIDToken = Date(timeIntervalSinceNow: TimeInterval(60 * 60 * 24 * 30))
      
      return MyIDToken(
         tokenString: [UInt8].random(count: 32).hex,
         issuer: "OAuth Server",
         subject: subject,
         audience: ["Client"],
         expiration: expiryTimeIDToken,
         issuedAt: Date(),
         nonce: nonce,
         authTime: nil
      )
      
   }

   // ----------------------------------------------------------

   func isUserEntitled(user userID: String?, scopes: [String]?) async throws -> Bool {

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

      // Return true if all requestedScopes are part of the user scopes
      return requestedScopes.isSubset(of: userScopes)

   }

}
