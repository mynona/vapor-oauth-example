import Vapor
import Leaf

extension OAuthClient {

   /// /oauth/logout
   ///
   /// Calls OpenID Provider endpoint to logout users and destroy current server session. On the Relying Party (Client) the cookies with tokens are destroyed.
   ///
   /// - Throws: [OAuthClientErrors](x-source-tag://OAuthClientErrors)
   ///
   static func logout(
      _ request: Request
   ) async throws -> Response {

      // Call /oauth/logout with Server Session Cookie

      let cookie = request.cookies[serverSessionCookieName] ?? ""

      let headers = HTTPHeaders(dictionaryLiteral:
                                 ("Cookie", "\(serverSessionCookieName)=\(cookie.string)")
      )

      do {
         _ = try await request.client.get(
            URI(string: "\(oAuthProvider)/oauth/logout"),
            headers: headers
         )
      } catch {
         throw OAuthClientErrors.openIDProviderResponseError("Calling /oauth/logout failed.")
      }

      // Create response with deletion cookies

      let response = try await request.view.render(
         "index"
      ).encodeResponse(for: request)

      let deleteCookie = HTTPCookies.Value(
         string: "",
         expires: Date(timeIntervalSince1970: 0.0),
         maxAge: 0,
         domain: nil,
         path: nil,
         isSecure: false,
         isHTTPOnly: true,
         sameSite: nil
      )

      response.cookies["access_token"] = deleteCookie
      response.cookies["refresh_token"] = deleteCookie
      response.cookies["id_token"] = deleteCookie
      response.cookies[serverSessionCookieName] = deleteCookie

      return response

   }

}
