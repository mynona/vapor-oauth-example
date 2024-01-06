import VaporOAuth
import Vapor
import Fluent

extension MyAuthorizationCodeManger {

   /// Generate Authorization Code
   func generateCode(userID: String, clientID: String, redirectURI: String, scopes: [String]?, codeChallenge: String?, codeChallengeMethod: String?) throws -> String {


      // NONCE MISSING AS PARAMETER IN CODE GENERATION
      

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
         nonce: "fake-in-generate-code-function" // FAKE IT FOR TESTING PURPOSES
      )

      _ = authorizationCode.save(on: app.db)

      return generatedCode
   }

   
}
