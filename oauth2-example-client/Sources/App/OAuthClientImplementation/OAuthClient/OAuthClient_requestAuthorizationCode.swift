import Vapor
import Leaf
import JWTKit

extension OAuthClient {

   /// Starts the Authentication flow
   ///
   /// PKCE:
   /// - code verifier is SHA256 hashed. The hashed code is sent as code_challenge together with the code_challenge_method as String ("SHA256") which indicates the hashing method
   ///
   /// Open ID:
   /// - The nonce parameter is included as value in the id_token
   ///
   /// At the moment the cookies are not returned when the Authorization Code is returned to the relaying party (client). Therefore, the code_verifier and nonce are hardcoded values.
   ///
   /// - Throws: [OAuthClientErrors](x-source-tag://OAuthClientErrors)
   ///
   static func requestAuthorizationCode(
      _ request: Request
   ) async throws -> Response {

      guard
         let verifierData = codeVerifier.data(using: .utf8)
      else {
         throw Abort(.internalServerError, reason: "PKCE Code could not be generated")
      }

      let verifierHash = SHA256.hash(data: verifierData)

      let codeChallenge = Data(verifierHash).base64URLEncodedString()

#if DEBUG
      print("\n-----------------------------")
      print("OAuthClient() \(#function)")
      print("-----------------------------")
      print("codeVerifier: \(codeVerifier)")
      print("\(verifierHash)")
      print("codeChallenge: \(codeChallenge)")
      print("nonce: \(nonce)")
      print("-----------------------------")
#endif

      let content = OAuthClientAuthorizationRequest(
         client_id: clientID,
         redirect_uri: "\(callbackURL)/callback",
         state: stateVerifier,
         response_type: "code",
         scope: ["openid"],
         code_challenge: "\(codeChallenge)",
         code_challenge_method: "S256",
         nonce: nonce
      )

      let uri = "\(oAuthProvider)/oauth/authorize?client_id=\(content.client_id)&redirect_uri=\(content.redirect_uri)&scope=\(content.scope.joined(separator: ","))&response_type=\(content.response_type)&state=\(content.state)&code_challenge=\(content.code_challenge)&code_challenge_method=\(content.code_challenge_method)&nonce=\(nonce)"

#if DEBUG
      print("\n-----------------------------")
      print("OAuthClient() \(#function)")
      print("-----------------------------")
      print("Authorization request sent to oauth server:")
      print("URI: \(uri)")
      print("-----------------------------")
#endif

      return request.redirect(to: uri)

   }

}
