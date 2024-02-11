import Vapor
import Leaf
import VaporOAuth
import Fluent


extension Controller {

   func loginForward(_ request: Request) async throws -> Response {
      
      let state = request.session.data["state"] ?? ""
      let client_id = request.session.data["client_id"] ?? ""
      let scope = request.session.data["scope"] ?? ""
      let redirect_uri = request.session.data["redirect_uri"] ?? ""
      let csrfToken = request.session.data["CSRFToken"] ?? ""
      let code_challenge = request.session.data["code_challenge"] ?? ""
      let code_challenge_method = request.session.data["code_challenge_method"] ?? ""
      let nonce = request.session.data["nonce"] ?? ""
      
#if DEBUG
      print("\n-----------------------------")
      print("Controller() \(#function)")
      print("-----------------------------")
      print("state: \(state)")
      print("client_id: \(client_id)")
      print("scope: \(scope)")
      print("redirect_uri: \(redirect_uri)")
      print("csrfToken: \(csrfToken)")
      print("code_challenge: \(code_challenge)")
      print("code_challenge_method: \(code_challenge_method)")
      print("nonce: \(nonce)")
      print("-----------------------------")
#endif
      
      struct Temp: Content {
         let applicationAuthorized: Bool
         let csrfToken: String
         let code_challenge: String
         let code_challenge_method: String
         let nonce: String
      }
      
      let content = Temp(
         applicationAuthorized: true,
         csrfToken: csrfToken,
         code_challenge: code_challenge,
         code_challenge_method: code_challenge_method,
         nonce: nonce
      )
      
      let authorize = URI(string: "http://localhost:8090/oauth/authorize?client_id=\(client_id)&redirect_uri=\(redirect_uri)&response_type=code&scope=\(scope)&state=\(state)&nonce=\(nonce)")
      
#if DEBUG
      print("\n-----------------------------")
      print("Controller() \(#function)")
      print("-----------------------------")
      print("url: \(authorize)")
      print("-----------------------------")
#endif
      
      let cookie = request.cookies["oauth-session"] ?? ""

      let headers = HTTPHeaders(dictionaryLiteral:
                                 ("Cookie", "oauth-session=\(cookie.string)")
      )
      
#if DEBUG
      print("\n-----------------------------")
      print("Controller() \(#function)")
      print("-----------------------------")
      print("headers: \(headers)")
      print("uri: \(authorize)")
      print("content: \(content)")
      print("-----------------------------")
#endif
      
      // Make sure session cookie is forwarded
      
      let response = try await request.client.post(
         authorize,
         headers: headers, 
         content: content
      ).encodeResponse(for: request)
      
      response.cookies["oauth-session"] = cookie
      
#if DEBUG
      print("\n-----------------------------")
      print("Controller() \(#function)")
      print("-----------------------------")
      print("response: \(response.headers)")
      print("-----------------------------")
#endif
      
      return response
      
   }

}
