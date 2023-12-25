import Vapor
import VaporOAuth
import Fluent
import JWT

extension MyTokenManager {

   func generateTokens(clientID: String, userID: String?, scopes: [String]?, accessTokenExpiryTime: Int, idTokenExpiryTime: Int, nonce: String?) async throws -> (VaporOAuth.AccessToken, VaporOAuth.RefreshToken, VaporOAuth.IDToken) {

      // Open ID not implemented

      let tempAccessToken = MyAccessToken(id: UUID(), tokenString: "", clientID: "", userID: nil, scopes: nil, expiryTime: Date())

      let tempRefreshToken = MyRefreshToken(tokenString: "", clientID: "", expiryTime: Date())

      let tempIDToken = MyIDToken(tokenString: "", issuer: "", subject: "", audience: [""], expiration: Date(), issuedAt: Date(), nonce: "", authTime: Date())

      return (tempAccessToken, tempRefreshToken, tempIDToken)

   }

}
