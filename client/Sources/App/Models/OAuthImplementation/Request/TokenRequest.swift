import Vapor

/// Request Token with Authorization Code via /oauth/token
/// - Parameters:
///   - code: The authorization code received in response to the authentication request.
///   - grant_type: “authorization_code” is used when exchanging an authorization code for tokens.
///   - redirect_uri: Callback location at the application for the OpenID Provider’s response from this call.
///   - client_id: The client ID for the relying party application, obtained when it registered with the OpenID Provider (authorization server)
///   - client_secret: Secret for the client application for the oauth server
///   - code_verifier: The PKCE code verifier value from which the code challenge in the authentication request was derived. It should be an unguessable, cryptographically random string between 43 and 128 characters in length, inclusive, using the characters A–Z, a–z, 0–9, “-”, “.”, “_”, and “~”.
///
public struct OAuthClientTokenRequest: Content {

   public let code: String
   public let grant_type: String
   public let redirect_uri: String
   public let client_id: String
   public let client_secret: String
   public let code_verifier: String

   public init(
      code: String,
      grant_type: String,
      redirect_uri: String,
      client_id: String,
      client_secret: String,
      code_verifier: String
   ) {
      self.code = code
      self.grant_type = grant_type
      self.redirect_uri = redirect_uri
      self.client_id = client_id
      self.client_secret = client_secret
      self.code_verifier = code_verifier
   }
}
