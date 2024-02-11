import Vapor

class OAuthTokenRefresher {
    private let oAuthProviderURL: String
    private let clientID: String
    private let clientSecret: String
    private let resourceServerUsername: String
    private let resourceServerPassword: String

    init(oAuthProviderURL: String, clientID: String, clientSecret: String, resourceServerUsername: String, resourceServerPassword: String) {
        self.oAuthProviderURL = oAuthProviderURL
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.resourceServerUsername = resourceServerUsername
        self.resourceServerPassword = resourceServerPassword
    }

    func exchangeRefreshTokenForNewTokens(_ request: Request) async throws -> OAuthClientRefreshTokenResponse {
        guard let refreshToken = request.cookies["refresh_token"]?.string else {
            throw OAuthClientErrors.tokenCookieNotFound(.RefreshToken)
        }

        let credentials = "\(self.resourceServerUsername):\(self.resourceServerPassword)".base64String()
        let headers = HTTPHeaders(dictionaryLiteral: ("Authorization", "Basic \(credentials)"))

        let content = OAuthClientRefreshTokenRequest(
            grant_type: "refresh_token",
            client_id: self.clientID,
            client_secret: self.clientSecret,
            refresh_token: refreshToken
        )

        let response = try await request.client.post(
            URI(string: "\(self.oAuthProviderURL)/oauth/token"),
            headers: headers,
            content: content
        )

        guard response.status == .ok else {
            throw OAuthClientErrors.openIDProviderResponseError("\(response.status)")
        }

        let tokenResponse: OAuthClientRefreshTokenResponse
        do {
            tokenResponse = try response.content.decode(OAuthClientRefreshTokenResponse.self)
        } catch {
            throw OAuthClientErrors.validationError("Refresh Token response could not be decoded.")
        }

        return tokenResponse
    }
}
