import VaporOAuth
import Vapor
import Fluent

extension MyAuthorizationCodeManger {

   /// Generate Authorization Code
   func generateCode(userID: String, clientID: String, redirectURI: String, scopes: [String]?, codeChallenge: String?, codeChallengeMethod: String?) throws -> String {

#if DEBUG
      print("\n-----------------------------")
      print("MyCodeManager() \(#function)")
      print("-----------------------------")
      print("Called with parameters:")
      print("userID: \(userID)")
      print("clientID: \(clientID)")
      print("redirectURI: \(redirectURI)")
      print("scopes: \(scopes)")
      print("-----------------------------")
#endif

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
         code_challenge_method: codeChallengeMethod
      )

      _ = authorizationCode.save(on: app.db)

      return generatedCode
   }

   
}
