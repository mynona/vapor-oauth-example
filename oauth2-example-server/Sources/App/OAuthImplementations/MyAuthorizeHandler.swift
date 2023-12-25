import Vapor
import VaporOAuth
import Leaf

struct MyAuthorizeHandler: AuthorizeHandler {

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
      // In this example sign in with username and password

      return try await request.view.render("signin", viewContext).encodeResponse(for: request)
   }

   // ----------------------------------------------------------

   /// - Throws: invalidClientID 
   /// - Throws: confidentialClientTokenGrant
   /// - Throws: invalidRedirectURI
   /// - Throws: httpRedirectURI
   func handleAuthorizationError(_ errorType: AuthorizationError) async throws -> Response {

#if DEBUG
      print("\n-----------------------------")
      print("MyAuthorizeHandler() \(#function)")
      print("-----------------------------")
      print("Authorization error")
      print("\(errorType)")
      print("-----------------------------")
#endif

      return Response(status: .unauthorized, body: .init(string: errorType.localizedDescription))
   }

}

