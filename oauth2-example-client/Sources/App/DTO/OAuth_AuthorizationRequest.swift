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

   // Code Challenge
   public let code_challenge: String

   // Code Challenge Method
   public let code_challenge_method: String

   public init(
      client_id: String,
      redirect_uri: String,
      state: String,
      response_type: String = "code",
      scope: [String],
      code_challenge: String,
      code_challenge_method: String
   ) {
      self.client_id = client_id
      self.redirect_uri = redirect_uri
      self.state = state
      self.response_type = response_type
      self.scope = scope
      self.code_challenge = code_challenge
      self.code_challenge_method = code_challenge_method
   }
}
