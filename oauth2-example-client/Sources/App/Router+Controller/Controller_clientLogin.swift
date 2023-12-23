import Vapor
import Foundation
import Leaf
import Crypto

extension Controller {

   func clientLogin(_ request: Request) async throws -> Response {

      // PKCE
      let codeVerifier = [UInt8].random(count: 128).hex
      guard
         let verifierData = codeVerifier.data(using: .utf8)
      else {
         throw Abort(.imATeapot, reason: "PKCE Code could not be generated")
      }
      //let hashed = SHA256.hash(data: Data(codeVerifier.utf8))
      let verifierHash = SHA256.hash(data: verifierData)

      //let codeChallenge = hashed.compactMap { String(format: "%02x", $0) }.joined()
      let codeChallenge = Data(verifierHash).base64URLEncodedString()


      // FAKE FAKE FAKE FAKE FAKE FAKE

      //let codeChallenge = "cfbb15d50a8c2f4502988e6cd97e78c1f234c6a4d0ed7d193562d9dbdbc30ba6"

#if DEBUG
      print("\n-----------------------------")
      print("Controller().login()")
      print("-----------------------------")
      print("Code challenge:")
      print("codeVerifier: \(codeVerifier)")
      print("\(verifierHash)")
      print("codeChallenge: \(codeChallenge)")
      print("-----------------------------")
#endif

      let content = OAuth_AuthorizationRequest(
         client_id: "1",
         redirect_uri: "http://localhost:8089/callback",
         state: "ping-pong",
         response_type: "code",
         scope: ["admin"],
         code_challenge: "\(codeChallenge)",
         code_challenge_method: "S256"
      )





      let uri = "http://localhost:8090/oauth/authorize?client_id=\(content.client_id)&redirect_uri=\(content.redirect_uri)&scope=\(content.scope.joined(separator: ","))&response_type=\(content.response_type)&state=\(content.state)&code_challenge=\(content.code_challenge)&code_challenge_method=\(content.code_challenge_method)"

#if DEBUG
      print("\n-----------------------------")
      print("Controller().login()")
      print("-----------------------------")
      print("Authorization request sent to oauth server:")
      print("URI: \(uri)")
      print("-----------------------------")
#endif

      return request.redirect(to: uri)

   }

}

// Helper extension for base64 URL encoding
extension Data {
    func base64URLEncodedString() -> String {
        return self.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
