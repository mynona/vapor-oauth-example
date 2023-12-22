import Vapor
import VaporOAuth
import Fluent
import JWT



class MyTokenManager: TokenManager {

   private let app: Application

   init(app: Application) {
      self.app = app
   }

   // ----------------------------------------------------------

   // Access and Refresh Token that are generated during
   // in exchange for the Authorization Code:

   func generateAccessRefreshTokens(clientID: String, userID: String?, scopes: [String]?, accessTokenExpiryTime: Int) async throws -> (VaporOAuth.AccessToken, VaporOAuth.RefreshToken) {

      let tokenString = UUID().uuidString

      // Expiry time 1 minutes
      // for testing of the flows
      let expiryTime = Date(timeIntervalSinceNow: TimeInterval(60))

      let payload = Payload(
         subject: SubjectClaim(value: userID ?? ""),
         expiration: ExpirationClaim(value: expiryTime),
         issuer: "OAuth Server",
         audience: "Client",
         jti: tokenString,
         issuedAtTime: Date()
      )

      let jwt = try app.jwt.signers.sign(payload)

      // Access Token sent to client

      let jwtAccessToken = MyAccessToken(
         tokenString: "\(jwt)",
         clientID: clientID,
         userID: userID,
         scopes: scopes,
         expiryTime: expiryTime
      )

      // Access Token stored in database

      let accessToken = MyAccessToken(
         tokenString: tokenString,
         clientID: clientID,
         userID: userID,
         scopes: scopes,
         expiryTime: expiryTime
      )
      try await accessToken.save(on: app.db)

      let refreshToken = MyRefreshToken(
         tokenString: UUID().uuidString,
         clientID: clientID,
         userID: userID,
         scopes: scopes
      )
      try await refreshToken.save(on: app.db)

      return (jwtAccessToken, refreshToken)
   }

   // ----------------------------------------------------------


   // generateAccessToken
   // Called when a refresh token is exchanged for an access token

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

      let tokenString = UUID().uuidString

      // Expiry time 1 minutes
      // for testing of the flows
      let xexpiryTime = Date(timeIntervalSinceNow: TimeInterval(60))

      let payload = Payload(
         subject: SubjectClaim(value: userID ?? ""),
         expiration: ExpirationClaim(value: xexpiryTime),
         issuer: "OAuth Server",
         audience: "Client",
         jti: tokenString,
         issuedAtTime: Date()
      )

      let jwt = try app.jwt.signers.sign(payload)

      let jwtAccessToken = MyAccessToken(
         tokenString: "\(jwt)",
         clientID: clientID,
         userID: userID,
         scopes: scopes,
         expiryTime: xexpiryTime
      )

      // Access Token stored in database

      let accessToken = MyAccessToken(
         tokenString: tokenString,
         clientID: clientID,
         userID: userID,
         scopes: scopes,
         expiryTime: xexpiryTime
      )
      try await accessToken.save(on: app.db)

      let refreshToken = MyRefreshToken(
         tokenString: UUID().uuidString,
         clientID: clientID,
         userID: userID,
         scopes: scopes
      )
      try await refreshToken.save(on: app.db)

      return jwtAccessToken

   }


   // ----------------------------------------------------------

   // Called by Token introspection
   // Client sends JWT token

   func getAccessToken(_ accessToken: String) async throws -> VaporOAuth.AccessToken? {

      // Search for tokenString provided as unique key jti
      let jwt = try app.jwt.signers.verify(accessToken, as: Payload.self)

      guard
         let token = try await MyAccessToken.query(on: app.db)
            .filter(\.$tokenString == jwt.jti)
            .first()
      else {
         return nil
      }

      // Delete expired access tokens for this user

      if let id = token.id {
         let expiredTokens = try await MyAccessToken
            .query(on: app.db)
            .filter(\.$userID == token.userID)
            .filter(\.$expiryTime < token.expiryTime)
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
      print("Database access token: \(token)")
      print("-----------------------------")
#endif

      // Return token from the database

      return MyAccessToken(
         id: token.id,
         tokenString: token.tokenString,
         clientID: token.clientID,
         userID: token.userID,
         scopes: token.scopes,
         expiryTime: token.expiryTime
      )

   }

   // ----------------------------------------------------------

   // Called when refresh_token is exchanged for an access_token

   func getRefreshToken(_ refreshToken: String) async throws -> VaporOAuth.RefreshToken? {

      guard
         let refreshToken = try await MyRefreshToken
            .query(on: app.db)
            .filter(\.$tokenString == refreshToken)
            .first()
      else {
         return nil
      }

      // Delete all other issued refresh tokens for this user
      // A user can have only one valid refresh token at a time
      // You need to customize this to your use case in case
      // you expect your users to access your application
      // from multiple devices / browsers / scopes, etc.
      // You might for example add an expiry data also for
      // refresh tokens.

      if let id = refreshToken.id {
         let otherActiveRefreshTokens = try await MyRefreshToken
            .query(on: app.db)
            .filter(\.$userID == refreshToken.userID)
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

   // When is this called?

   func updateRefreshToken(_ refreshToken: VaporOAuth.RefreshToken, scopes: [String]) async {

#if DEBUG
      print("\n-----------------------------")
      print("MyTokenManager().updateRefreshToken()")
      print("-----------------------------")
      print("-----------------------------")
#endif


   }

}
