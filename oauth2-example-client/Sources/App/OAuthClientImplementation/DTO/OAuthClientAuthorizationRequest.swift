import Vapor

/// Request Authorization Code via /oauth/authorize
/// - Parameters:
///   - client_id: The client ID for the relying party application, obtained when it registered with the OpenID Provider (authorization server)
///   - redirect_uri: URI where the OpenID Provider directs the response upon completion of the authentication request.
///   - state: An unguessable value passed to the OpenID Provider in the request. The OpenID Provider is supposed to return the exact same state parameter and value in a success response. Used by the relying party application to validate the response corresponds to a request it sent previously. This helps protect against token injection and CSRF (Cross-Site Request Forgery).
///   - response_type: The response type indicates which OIDC flow to use. “code” indicates that the Authorization Code Flow should be used.
///   - scope: A string specifying the claims requested about the authenticated user. Example scope: ["openid","profile","email"]
///   - code_challenge: PKCE code challenge derived from the PKCE code verifier using the code challenge method specified in the code_challenge_method parameter.
///   - code_challenge_method: “S256” or “plain.” Applications capable of using S256 (SHA256 hash) must use it.
///   - nonce: An unguessable value passed to the OpenID Provider in the request and returned unmodified as a claim in the ID Token if an ID Token is requested. Used to protect against token replay.
///
public struct OAuthClientAuthorizationRequest: Content {

   public let client_id: String
   public let redirect_uri: String
   public let state: String
   public let response_type: String
   public let scope: [String]
   public let code_challenge: String
   public let code_challenge_method: String
   public let nonce: String

   public init(
      client_id: String,
      redirect_uri: String,
      state: String,
      response_type: String = "code",
      scope: [String],
      code_challenge: String,
      code_challenge_method: String,
      nonce: String
   ) {
      self.client_id = client_id
      self.redirect_uri = redirect_uri
      self.state = state
      self.response_type = response_type
      self.scope = scope
      self.code_challenge = code_challenge
      self.code_challenge_method = code_challenge_method
      self.nonce = nonce
   }
}
