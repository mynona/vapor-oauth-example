import VaporOAuth
import Vapor

class MyCodeManger: CodeManager {


   // Device Code flow not part of this example:

   func generateDeviceCode(userID: String, clientID: String, scopes: [String]?) async throws -> String { return "" }

   func getDeviceCode(_ deviceCode: String) async throws -> VaporOAuth.OAuthDeviceCode? { return nil }

   func deviceCodeUsed(_ deviceCode: VaporOAuth.OAuthDeviceCode) async throws { }

   // ----------------------------------------------------------

   private(set) var usedCodes: [String] = []
   private(set) var codes: [String: OAuthCode] = [:]

   func generateCode(userID: String, clientID: String, redirectURI: String, scopes: [String]?) throws -> String {

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
      let code = OAuthCode(
         codeID: generatedCode,
         clientID: clientID,
         redirectURI: redirectURI,
         userID: userID,
         expiryDate: Date().addingTimeInterval(60),
         scopes: scopes
      )
      codes[generatedCode] = code
      return generatedCode
   }

   func getCode(_ code: String) -> OAuthCode? {

#if DEBUG
      print("\n-----------------------------")
      print("MyCodeManager().getCode()")
      print("-----------------------------")
      print("Called with parameters:")
      print("code: \(code)")
      print("-----------------------------")
#endif

      return codes[code]
   }

   func codeUsed(_ code: OAuthCode) {

#if DEBUG
      print("\n-----------------------------")
      print("MyCodeManager().codeUsed()")
      print("-----------------------------")
      print("Called with parameters:")
      print("code: \(code.codeID)")
      print("-----------------------------")
#endif

      usedCodes.append(code.codeID)
      codes.removeValue(forKey: code.codeID)
   }
}
