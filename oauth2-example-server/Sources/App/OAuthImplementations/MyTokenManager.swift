import Vapor
import VaporOAuth
import Fluent
import JWT

class MyTokenManager: TokenManager {

   private let app: Application

   // ----------------------------------------------------------

   init(app: Application) {
      self.app = app
   }

   // ----------------------------------------------------------

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
         expiryTime: expiryTimeRefreshToken
      )

   }

   // ----------------------------------------------------------

   /// Generate Access and Refresh Token in exchange for the Authorization Code
   func generateAccessRefreshTokens(clientID: String, userID: String?, scopes: [String]?, accessTokenExpiryTime: Int) async throws -> (VaporOAuth.AccessToken, VaporOAuth.RefreshToken) {

      let accessTokenUniqueId = UUID().uuidString

      // Expiry time 1 minutes for testing purposes
      let expiryTimeAccessToken = Date(timeIntervalSinceNow: TimeInterval(60))

      let jwt = try createJWT(
         subject: userID ?? "",
         expiration: expiryTimeAccessToken,
         issuer: "OAuth Server",
         audience: "Client",
         jti: accessTokenUniqueId,
         issuedAtTime: Date()
      )

      // Access Token for Database
      let accessToken = try createAccessToken(
         tokenString: accessTokenUniqueId,
         clientID: clientID,
         userID: userID,
         scopes: scopes,
         expiryTime: expiryTimeAccessToken
      )

      try await accessToken.save(on: app.db)

      // Access Token for Client: replace the token with the JWT
      accessToken.tokenString = jwt

      // Refresh Token
      let refreshToken = try createRefreshToken(
         clientID: clientID,
         userID: userID,
         scopes: scopes
      )

      try await refreshToken.save(on: app.db)

      return (accessToken, refreshToken)
   }

   // ----------------------------------------------------------

   /// Generate new Access Token in exchange for the Refresh Token
   func generateAccessToken(clientID: String, userID: String?, scopes: [String]?, expiryTime: Int) async throws -> VaporOAuth.AccessToken {

#if DEBUG
      print("\n-----------------------------")
      print("MyTokenManager().generateAccessToken()")
      print("-----------------------------")
      print("Parameters:")
      print("clientID: \(clientID)")
      print("userID: \(userID)")
      print("scopes: \(scopes)")
      print("expiryTime: \(expiryTime)")
      print("-----------------------------")
#endif

      let accessTokenUniqueId = UUID().uuidString

      // Expiry time 1 minutes for testing purposes
      let expiryTimeAccessToken = Date(timeIntervalSinceNow: TimeInterval(60))

      let jwt = try createJWT(
         subject: userID ?? "",
         expiration: expiryTimeAccessToken,
         issuer: "OAuth Server",
         audience: "Client",
         jti: accessTokenUniqueId,
         issuedAtTime: Date()
      )

      // Access Token for Database
      let accessToken = try createAccessToken(
         tokenString: accessTokenUniqueId,
         clientID: clientID,
         userID: userID,
         scopes: scopes,
         expiryTime: expiryTimeAccessToken
      )

      try await accessToken.save(on: app.db)

      // Access Token for Client: replace the token with the JWT
      accessToken.tokenString = jwt

      return accessToken

   }


   // ----------------------------------------------------------

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

   // ----------------------------------------------------------

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

   // ----------------------------------------------------------

   /// Update Refresh Token scope
   func updateRefreshToken(_ refreshToken: VaporOAuth.RefreshToken, scopes: [String]) async throws {

#if DEBUG
      print("\n-----------------------------")
      print("MyTokenManager().updateRefreshToken()")
      print("-----------------------------")
      print("Parameter: \(refreshToken)")
      print("-----------------------------")
#endif

      if let token = try await MyRefreshToken
         .query(on: app.db)
         .filter(\.$tokenString == refreshToken.tokenString)
         .first() {

         token.scopes = scopes

         try await token.save(on: app.db)

      }
   }

}
