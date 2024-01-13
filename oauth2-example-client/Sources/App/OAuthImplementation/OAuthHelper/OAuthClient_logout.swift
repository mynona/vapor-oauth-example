import Vapor
import Leaf

extension OAuthClient {

   static func logout(_ request: Request) async throws -> Response {

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

      // Logout and destroy server session

      let cookie = request.cookies["vapor-session"] ?? ""

      let headers = HTTPHeaders(dictionaryLiteral:
                                 ("Cookie", "vapor-session=\(cookie.string)")
      )

      let _ = try await request.client.get(URI(string: "\(oAuthProvider)/oauth/logout"), headers: headers)

      let view = try await request.view.render(
         "index"
      )

      let res = try await view.encodeResponse(for: request)
      res.cookies["access_token"] = deleteCookie
      res.cookies["refresh_token"] = deleteCookie
      res.cookies["id_token"] = deleteCookie
      res.cookies["vapor-session"] = deleteCookie
      return res

   }

}
