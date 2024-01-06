import VaporOAuth
import Vapor
import Fluent

extension MyAuthorizationCodeManger {

   /// Generate Authorization Code
   func generateCode(userID: String, clientID: String, redirectURI: String, scopes: [String]?, codeChallenge: String?, codeChallengeMethod: String?, nonce: String?) throws -> String {

      let generatedCode = UUID().uuidString
      let expiryDate = Date().addingTimeInterval(60)

      let authorizationCode = MyAuthorizationCode(
         code_id: generatedCode,
         client_id: clientID,
         redirect_uri: redirectURI,
         user_id: userID,
         expiry_date: expiryDate,
         scopes: scopes,
         code_challenge: codeChallenge,
         code_challenge_method: codeChallengeMethod,
         nonce: nonce
      )

      _ = authorizationCode.save(on: app.db)

      return generatedCode
   }

   
}
