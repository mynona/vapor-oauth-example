import Vapor
import VaporOAuth
import Fluent
import JWT

extension MyTokenManager {
   
   /// Generate Access and Refresh Token in exchange for the Authorization Code
   func generateAccessRefreshTokens(clientID: String, userID: String?, scopes: [String]?, accessTokenExpiryTime: Int) async throws -> (VaporOAuth.AccessToken, VaporOAuth.RefreshToken) {

      let accessToken = try await generateAccessToken(clientID: clientID, userID: userID, scopes: scopes, expiryTime: accessTokenExpiryTime)

      let refreshToken = try await generateRefreshToken(clientID: clientID, userID: userID, scopes: scopes)

      return (accessToken, refreshToken)
   }

}
