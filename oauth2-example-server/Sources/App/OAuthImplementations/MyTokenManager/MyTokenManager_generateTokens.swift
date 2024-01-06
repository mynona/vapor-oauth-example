import Vapor
import VaporOAuth
import Fluent
import JWTKit

extension MyTokenManager {

   func generateTokens(clientID: String, userID: String?, scopes: [String]?, accessTokenExpiryTime: Int, idTokenExpiryTime: Int, nonce: String?) async throws -> (VaporOAuth.AccessToken, VaporOAuth.RefreshToken, VaporOAuth.IDToken) {

#if DEBUG
      print("\n-----------------------------")
      print("MyTokenManager() \(#function)")
      print("-----------------------------")
      print("Parameters:")
      print("clientID: \(clientID)")
      print("userID: \(userID)")
      print("scopes: \(scopes)")
      print("accessTokenExpiryTime: \(accessTokenExpiryTime)")
      print("idTokenExpiryTime: \(idTokenExpiryTime)")
      print("nonce: \(nonce)")
      print("-----------------------------")
#endif

      let accessToken = try await generateAccessToken(clientID: clientID, userID: userID, scopes: scopes, expiryTime: accessTokenExpiryTime)

      let refreshToken = try await generateRefreshToken(clientID: clientID, userID: userID, scopes: scopes)

      let idToken = try await generateIDToken(clientID: clientID, userID: userID ?? "", scopes: scopes, expiryTime: idTokenExpiryTime, nonce: nonce)

      return (accessToken, refreshToken, idToken)

   }

}
