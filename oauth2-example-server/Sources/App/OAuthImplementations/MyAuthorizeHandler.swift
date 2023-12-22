import Vapor
import VaporOAuth
import Leaf

struct MyAuthorizeHandler: AuthorizeHandler {

   func handleAuthorizationRequest(_ request: Request, authorizationRequestObject: AuthorizationRequestObject) async throws -> Response {

#if DEBUG
      print("\n-----------------------------")
      print("MyAuthorizeHandler().handleAuthorizationRequest()")
      print("-----------------------------")
      print("Authorization request received from the client:")
      print("\(authorizationRequestObject)")
      print("-----------------------------")
#endif

      let viewContext = SignInViewContext(
         csrfToken: authorizationRequestObject.csrfToken
      )

      // Persist data in session on the server
      // To be done: encrypt data

      request.session.data["state"] = authorizationRequestObject.state
      request.session.data["client_id"] = authorizationRequestObject.clientID
      request.session.data["scope"] = authorizationRequestObject.scope.joined(separator: ",")
      request.session.data["redirect_uri"] = authorizationRequestObject.redirectURI.string

      // Show login screen to user
      // In this example sign in with username and password

      // What is missing: The OAuthUser should be extended as model for fluent
      // This is just a workaround to see the full flow working before
      // I touch this topic. There is this old repository but it is not compatible
      // with the current Vapor versions:
      // https://github.com/brokenhandsio/vapor-oauth-fluent/blob/master/Sources/VaporOAuthFluent/Models/OAuthUser%2BFluent.swift

      return try await request.view.render("signin", viewContext).encodeResponse(for: request)
   }

   // ----------------------------------------------------------

   func handleAuthorizationError(_ errorType: AuthorizationError) async throws -> Response {

      /*
       Errors:
       case invalidClientID
       case confidentialClientTokenGrant
       case invalidRedirectURI
       case httpRedirectURI
       */

#if DEBUG
      print("\n-----------------------------")
      print("MyAuthorizeHandler().handleAuthorizationError()")
      print("-----------------------------")
      print("Authorization error")
      print("\(errorType)")
      print("-----------------------------")
#endif

      return Response(status: .unauthorized, body: .init(string: errorType.localizedDescription))
   }

}






