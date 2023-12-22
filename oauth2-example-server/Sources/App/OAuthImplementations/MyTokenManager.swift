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

      let payload = Payload(
         subject: SubjectClaim(value: userID ?? ""),
         expiration: ExpirationClaim(value: Date(timeIntervalSinceNow: TimeInterval(accessTokenExpiryTime))),
         issuer: "OAuth Server",
         audience: "Client",
         jti: tokenString,
         issuedAtTime: Date()
      )

      let jwt = try app.jwt.signers.sign(payload)

      // Expiry time


      let expiryTime = Date(timeIntervalSinceNow: TimeInterval(60))

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

   func generateAccessToken(clientID: String, userID: String?, scopes: [String]?, expiryTime: Int) async throws -> VaporOAuth.AccessToken {


#if DEBUG
      print("\n-----------------------------")
      print("MyTokenManager().generateAccessToken()")
      print("-----------------------------")
      print("-----------------------------")
#endif

      let accessToken = MyAccessToken(
         tokenString: UUID().uuidString,
         clientID: clientID,
         userID: userID,
         scopes: scopes,
         expiryTime: Date(timeIntervalSinceNow: TimeInterval(expiryTime))
      )
      try await accessToken.save(on: app.db)
      return accessToken
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
