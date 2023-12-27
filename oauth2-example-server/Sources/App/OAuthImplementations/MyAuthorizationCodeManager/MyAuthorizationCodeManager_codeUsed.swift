import VaporOAuth
import Vapor
import Fluent

extension MyAuthorizationCodeManger {

   /// Delete used Authorization Code
   func codeUsed(_ code: OAuthCode) async throws {

#if DEBUG
      print("\n-----------------------------")
      print("MyCodeManager() \(#function)")
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
