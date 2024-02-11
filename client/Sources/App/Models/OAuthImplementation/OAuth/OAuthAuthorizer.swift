import Vapor

class OAuthAuthorizer {
    private let oAuthProviderURL: String
    private let callbackURL: String
    private let clientID: String
    private let stateVerifier: String
    private let codeVerifier: String
    private let nonce: String

    init(oAuthProviderURL: String, callbackURL: String, clientID: String, stateVerifier: String, codeVerifier: String, nonce: String) {
        self.oAuthProviderURL = oAuthProviderURL
        self.callbackURL = callbackURL
        self.clientID = clientID
        self.stateVerifier = stateVerifier
        self.codeVerifier = codeVerifier
        self.nonce = nonce
    }

    func requestAuthorizationCode(_ request: Request) async throws -> Response {
        let codeChallenge = try self.generateCodeChallenge(from: codeVerifier)

        // Ensure a session is created and persisted
        request.session.data["state"] = stateVerifier
        request.session.data["nonce"] = nonce
        // You can store any other necessary data in the session as needed

        let authorizationURL = URI(string: "\(oAuthProviderURL)/oauth/authorize?client_id=\(clientID)&redirect_uri=\(callbackURL.urlEncoded())/callback&response_type=code&scope=openid&state=\(stateVerifier)&code_challenge=\(codeChallenge)&code_challenge_method=S256&nonce=\(nonce)")

        // The redirect response will include Set-Cookie headers for the session
        return request.redirect(to: authorizationURL.string)
    }

    private func generateCodeChallenge(from codeVerifier: String) throws -> String {
        guard let verifierData = codeVerifier.data(using: .utf8) else {
            throw OAuthClientErrors.invalidCodeVerifier
        }
        let verifierHash = SHA256.hash(data: verifierData)
        return Data(verifierHash).base64URLEncodedString()
    }
}

extension String {
    func urlEncoded() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? self
    }
}
