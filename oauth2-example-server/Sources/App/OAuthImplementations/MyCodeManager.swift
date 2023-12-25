import VaporOAuth
import Vapor
import Fluent

final class MyCodeManger: CodeManager {

   private let app: Application

   init(app: Application) {
      self.app = app
   }

   // Device Code flow not part of this example:

   func generateDeviceCode(userID: String, clientID: String, scopes: [String]?) async throws -> String { return "" }

   func getDeviceCode(_ deviceCode: String) async throws -> VaporOAuth.OAuthDeviceCode? { return nil }

   func deviceCodeUsed(_ deviceCode: VaporOAuth.OAuthDeviceCode) async throws { }

   // ----------------------------------------------------------


   // Generate Authorization Code

   func generateCode(userID: String, clientID: String, redirectURI: String, scopes: [String]?, codeChallenge: String?, codeChallengeMethod: String?) throws -> String {

#if DEBUG
      print("\n-----------------------------")
      print("MyCodeManager().generateCode()")
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

   // ----------------------------------------------------------

   // Retrieve Authorization code

   func getCode(_ code: String) async throws -> OAuthCode? {

#if DEBUG
      print("\n-----------------------------")
      print("MyCodeManager().getCode()")
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

   // ----------------------------------------------------------

   // Delete used Authorization Code

   func codeUsed(_ code: OAuthCode) async throws {

#if DEBUG
      print("\n-----------------------------")
      print("MyCodeManager().codeUsed()")
      print("-----------------------------")
      print("Called with parameters:")
      print("code: \(code.codeID)")
      print("-----------------------------")
#endif

      if let authorizationCode = try await MyAuthorizationCode.query(on: app.db)
         .filter(\.$code_id == code.codeID)
         .first() {

         try await authorizationCode
            .delete(on: app.db)
      }

   }
}
