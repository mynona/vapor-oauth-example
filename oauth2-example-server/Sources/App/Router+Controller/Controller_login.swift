import Vapor
import Leaf
import VaporOAuth
import Fluent

extension Controller {

   func login(_ request: Request) async throws -> Response {

      let user = try request.auth.require(Author.self)

#if DEBUG
      print("\n-----------------------------")
      print("Controller() \(#function)")
      print("-----------------------------")
      print("Credentials authenticator / Fluent:")
      print("\(user)")
      print("-----------------------------")
#endif

      // Log in OAuth user with credentials

      let oauth_user = OAuthUser(
            userID: user.id?.uuidString,
            username: user.username,
            emailAddress: "",
            password: user.password
         )

      request.auth.login(oauth_user)

      /*
       I encountered the problem that the session cookie is not updated immediately. The call to the authorization endpoint requires that the OAuthUser is already logged in. To overcome this issue (that still needs more investigation) I do a redirect. Once this is done the OAuthUser is properly logged in.
       */

      //return request.redirect(to: "http://localhost:8090/oauth/login-forward")


      // Make sure session cookie is correctly forwarded
      let cookie = request.cookies["vapor-session"]

      let response = try await request.redirect(to: "http://localhost:8090/oauth/login-forward").encodeResponse(for: request)
      response.cookies["vapor-session"] = cookie

         print(response)


      return response


   }


   
}
