import Vapor

class OAuthUserInfoFetcher {
    private let oAuthProviderURL: String

    init(oAuthProviderURL: String) {
        self.oAuthProviderURL = oAuthProviderURL
    }

    func userInfo(_ request: Request) async throws -> OAuthClientUserInfoResponse {
        guard let accessToken: String = request.cookies["access_token"]?.string else {
            throw OAuthClientErrors.tokenCookieNotFound(.AccessToken)
        }

        let headers = HTTPHeaders(dictionaryLiteral: ("Authorization", "Bearer \(accessToken)"))
        
        let response: ClientResponse
        do {
            response = try await request.client.get(
                URI(string: "\(oAuthProviderURL)/oauth/userinfo"),
                headers: headers
            )
        } catch {
            throw OAuthClientErrors.openIDProviderServerError
        }

        guard response.status == .ok else {
            throw OAuthClientErrors.openIDProviderResponseError("\(response.status)")
        }

        do {
            return try response.content.decode(OAuthClientUserInfoResponse.self)
        } catch {
            throw OAuthClientErrors.dataDecodingError("OAuth_UserInfoResponse decoding failed.")
        }
    }
}
