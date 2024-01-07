import Vapor
import Leaf

extension Controller {


   func callback(_ request: Request) async throws -> Response {

      /*
       There is an issue that cookies are not returned to the /callback
       This issue has already been reported. If no session cookie it is hard
       to persist the code_verifier and state across calls in a secure way.
       */

#if DEBUG
      print("\n-----------------------------")
      print("Controller() \(#function)")
      print("-----------------------------")
      print("Request: \(request)")
      print("-----------------------------")
#endif

      let view = try await request.view.render(
         "protected-resource"
      )

      let res = try await view.encodeResponse(for: request)

      // Exchange Authorization Code for Access, Refresh and IDToken
      // Validate Token Signatures and Payloads
      let token = try await OAuthHelper.exchangeAuthorizationCodeForToken(request)

      // Persist retrieved tokens as cookies
      if let accessToken = token.accessToken {
         res.cookies["access_token"] = OAuthHelper.createCookie(withValue: accessToken, forToken: .AccessToken)
      }

      if let refreshToken = token.refreshToken {
         res.cookies["refresh_token"] = OAuthHelper.createCookie(withValue: refreshToken, forToken: .RefreshToken)
      }

      if let idToken = token.idToken {
         res.cookies["id_token"] = OAuthHelper.createCookie(withValue: idToken, forToken: .RefreshToken)
      }

      return res

   }

}
