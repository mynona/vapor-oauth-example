import Vapor
import Leaf

extension Controller {

   func clientLogout(_ request: Request) async throws -> Response {

      // Client logout will just destroy the cookies for testing purposes.
      // You might want to delete the access_token and the refresh_token.
      // This must be implemented on the server.

      let deleteCookie = HTTPCookies.Value(
         string: "",
         expires: Date(timeIntervalSince1970: 0.0),
         maxAge: 0,
         domain: nil,
         path: nil,
         isSecure: false, // in real world case: true
         isHTTPOnly: true,
         sameSite: nil
      )

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
