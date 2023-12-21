import Vapor

public struct OAuth_AuthorizationRequest: Content {

   // client application the user wants to access
   public let client_id: String

   // where should the oauth server redirect to after log in
   public let redirect_uri: String

   // value that is echoed back to the client from the oauth server
   // can be used if you need to persist something during the flow
   public let state: String

   // Authorization Grant = "code"
   public let response_type: String

   // Scope requested for this application
   public let scope: [String]

   // codeChallenge not supported

   public init(
      client_id: String,
      redirect_uri: String,
      state: String,
      response_type: String = "code",
      scope: [String]
   ) {
      self.client_id = client_id
      self.redirect_uri = redirect_uri
      self.state = state
      self.response_type = response_type
      self.scope = scope
   }
}
