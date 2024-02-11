import Vapor

class OAuthTokenExchanger {
    private let oAuthProviderURL: String
    private let callbackURL: String
    private let clientID: String
    private let clientSecret: String
    private let codeVerifier: String

    init(oAuthProviderURL: String, callbackURL: String, clientID: String, clientSecret: String, codeVerifier: String) {
        self.oAuthProviderURL = oAuthProviderURL
        self.callbackURL = callbackURL
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.codeVerifier = codeVerifier
    }

    func exchangeAuthorizationCodeForTokens(_ request: Request) async throws -> (accessToken: String?, refreshToken: String?, idToken: String?) {
        
        guard let code: String = request.query["code"] else {
            throw OAuthClientErrors.authorizationFlowParameterMissing("Required query parameter 'code' missing.")
        }

        let tokenEndpoint = URI(string: "\(self.oAuthProviderURL)/oauth/token")

        let content = OAuthClientTokenRequest(
            code: code,
            grant_type: "authorization_code",
            redirect_uri: "\(self.callbackURL)/callback",
            client_id: self.clientID,
            client_secret: self.clientSecret,
            code_verifier: self.codeVerifier
        )

        let response = try await request.client.post(tokenEndpoint, content: content)

        guard response.status == .ok else {
            throw OAuthClientErrors.openIDProviderResponseError("\(response.status)")
        }

        let authorizationResponse: OAuthClientAuthorizationResponse
        do {
            authorizationResponse = try response.content.decode(OAuthClientAuthorizationResponse.self)
        } catch {
            throw OAuthClientErrors.dataDecodingError("OAuth_AuthorizationResponse decoding failed.")
        }

        return (
            accessToken: authorizationResponse.accessToken,
            refreshToken: authorizationResponse.refreshToken,
            idToken: authorizationResponse.idToken
        )
    }
}
