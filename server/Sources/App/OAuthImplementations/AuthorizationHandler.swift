import Vapor
import VaporOAuth

/// Manage authorization flow
struct AuthorizationHandler: AuthorizeHandler {
    
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

        // Validate the input request object if needed
        
        // Persist data in session on the server
        request.session.data["state"] = authorizationRequestObject.state
        request.session.data["client_id"] = authorizationRequestObject.clientID
        request.session.data["scope"] = authorizationRequestObject.scope.joined(separator: " ")
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

       let viewContext = SignInViewContext(
          csrfToken: authorizationRequestObject.csrfToken
       )

      return try await request.view.render("login", viewContext).encodeResponse(for: request)

        
    }
    
    /// Handle Authorization Error
    func handleAuthorizationError(_ errorType: AuthorizationError) async throws -> Response {
        // Determine the appropriate HTTP status code based on the error type
        let statusCode: HTTPResponseStatus
        switch errorType {
        case .invalidClientID:
            statusCode = .badRequest
        case .confidentialClientTokenGrant:
            statusCode = .forbidden
        case .invalidRedirectURI, .httpRedirectURI:
            statusCode = .badRequest
        default:
            statusCode = .internalServerError
        }
        
        // Log the error using a proper logging mechanism
        // You can use a logging framework here
        
        // Construct a user-friendly error message
        // Be cautious about revealing too much information in the error message
        let errorMessage = "An error occurred during authorization." // Generic message for production
        
        // Create and return the response
        return Response(status: statusCode, body: .init(string: errorMessage))
    }
}

