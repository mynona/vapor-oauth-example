import Vapor
import VaporOAuth
import Leaf

extension MyAuthorizationHandler {

   /// Handle Authorization Request from the client
   func handleAuthorizationRequest(_ request: Request, authorizationRequestObject: AuthorizationRequestObject) async throws -> Response {

#if DEBUG
      print("\n-----------------------------")
      print("MyAuthorizeHandler() \(#function)")
      print("-----------------------------")
      print("Authorization request received from the client:")
      print("\(authorizationRequestObject)")
      print("-----------------------------")
#endif

      let viewContext = SignInViewContext(
         csrfToken: authorizationRequestObject.csrfToken
      )

      // Persist data in session on the server
      request.session.data["state"] = authorizationRequestObject.state
      request.session.data["client_id"] = authorizationRequestObject.clientID
      request.session.data["scope"] = authorizationRequestObject.scope.joined(separator: ",")
      request.session.data["redirect_uri"] = authorizationRequestObject.redirectURI.string
      request.session.data["code_challenge"] = authorizationRequestObject.codeChallenge ?? ""
      request.session.data["code_challenge_method"] = authorizationRequestObject.codeChallengeMethod ?? "S256"
      request.session.data["nonce"] = authorizationRequestObject.nonce

#if DEBUG
      print("\n-----------------------------")
      print("MyAuthorizeHandler() \(#function)")
      print("-----------------------------")
      print("Request session:")
      print("\(request.session.data)")
      print("-----------------------------")
#endif

      // Show login screen to user

      return try await request.view.render("login", viewContext).encodeResponse(for: request)

   }

}
