import VaporOAuth
import Vapor
import Fluent

extension MyCodeManger {

   /// Retrieve Authorization code
   func getCode(_ code: String) async throws -> OAuthCode? {

#if DEBUG
      print("\n-----------------------------")
      print("MyCodeManager() \(#function)")
      print("-----------------------------")
      print("Called with parameters:")
      print("code: \(code)")
      print("-----------------------------")
#endif

      guard
         let authorizationCode = try await MyAuthorizationCode.query(on: app.db)
            .filter(\.$code_id == code)
            .first()
      else { return nil }

      return OAuthCode(
         codeID: authorizationCode.code_id,
         clientID: authorizationCode.client_id,
         redirectURI: authorizationCode.redirect_uri,
         userID: authorizationCode.user_id,
         expiryDate: authorizationCode.expiry_date,
         scopes: authorizationCode.scopes,
         codeChallenge: authorizationCode.code_challenge,
         codeChallengeMethod: authorizationCode.code_challenge_method
      )

   }

}
