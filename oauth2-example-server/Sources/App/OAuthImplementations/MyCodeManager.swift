import VaporOAuth
import Vapor

class LiveCodeManger: CodeManager {
   func generateDeviceCode(userID: String, clientID: String, scopes: [String]?) async throws -> String {
      return ""
   }
   
   func getDeviceCode(_ deviceCode: String) async throws -> VaporOAuth.OAuthDeviceCode? {
      return OAuthDeviceCode(deviceCodeID: "", userCode: "", clientID: "", userID: "", expiryDate: Date(), scopes: nil)
   }
   
   func deviceCodeUsed(_ deviceCode: VaporOAuth.OAuthDeviceCode) async throws {

   }
   
    private(set) var usedCodes: [String] = []
    private(set) var codes: [String: OAuthCode] = [:]

    func generateCode(userID: String, clientID: String, redirectURI: String, scopes: [String]?) throws -> String {


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
        return codes[code]
    }

    func codeUsed(_ code: OAuthCode) {
        usedCodes.append(code.codeID)
        codes.removeValue(forKey: code.codeID)
    }
}
