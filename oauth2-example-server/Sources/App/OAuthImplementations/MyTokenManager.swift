import Vapor
import VaporOAuth
import Fluent
import FluentKit
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

/*
      let accessToken = MyAccessToken(
         tokenString: UUID().uuidString,
         clientID: clientID,
         userID: userID,
         scopes: scopes,
         expiryTime: Date(timeIntervalSinceNow: TimeInterval(expiryTime))
      )
      try await accessToken.save(on: app.db)
      return accessToken
 */
   }

   // ----------------------------------------------------------

   func getRefreshToken(_ refreshToken: String) async throws -> VaporOAuth.RefreshToken? {
      return try await MyRefreshToken.query(on: app.db)
         .filter(\.$tokenString == refreshToken)
         .first()
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

   func updateRefreshToken(_ refreshToken: VaporOAuth.RefreshToken, scopes: [String]) async {

#if DEBUG
      print("\n-----------------------------")
      print("MyTokenManager().uddateRefreshToken()")
      print("-----------------------------")
      print("-----------------------------")
#endif


   }

}
