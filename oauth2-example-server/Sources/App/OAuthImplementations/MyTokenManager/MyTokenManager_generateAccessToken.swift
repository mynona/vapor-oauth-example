import Vapor
import VaporOAuth
import Fluent
import JWTKit

extension MyTokenManager {

   /// Generate new Access Token in exchange for the Refresh Token
   func generateAccessToken(clientID: String, userID: String?, scopes: [String]?, expiryTime: Int) async throws -> VaporOAuth.AccessToken {

#if DEBUG
      print("\n-----------------------------")
      print("MyTokenManager() \(#function)")
      print("-----------------------------")
      print("Parameters:")
      print("clientID: \(clientID)")
      print("userID: \(userID)")
      print("scopes: \(scopes)")
      print("expiryTime: \(expiryTime)")
      print("-----------------------------")
#endif

      let entitlements = try await isUserEntitled(user: userID, scopes: scopes)

      guard
         entitlements.entitled == true
      else {
         throw Abort(.unauthorized, reason: "User is not entitled for this scope.")
      }

      let accessTokenUniqueId = UUID().uuidString

      // Expiry time 1 minutes for testing purposes
      let expiryTimeAccessToken = Date(timeIntervalSinceNow: TimeInterval(60))

      // Access Token for Database
      let accessToken = try createAccessToken(
         tokenString: accessTokenUniqueId,
         clientID: clientID,
         userID: userID,
         scopes: entitlements.scopes, 
         expiryTime: expiryTimeAccessToken
      )

      try await accessToken.save(on: app.db)

      let payload = JWT_AccessTokenPayload(
         jti: accessToken.tokenString,
         clientID: accessToken.clientID,
         userID: accessToken.userID,
         scopes: accessToken.scopes,
         expiryTime: accessToken.expiryTime,
         issuer: accessToken.issuer,
         issuedAt: Date()
      )

      return payload

   }


}
