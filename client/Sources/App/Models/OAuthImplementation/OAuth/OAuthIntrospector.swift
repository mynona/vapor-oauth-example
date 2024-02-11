import Vapor

class OAuthIntrospector {
    private let oAuthProviderURL: String
    private let resourceServerUsername: String
    private let resourceServerPassword: String

    init(oAuthProviderURL: String, resourceServerUsername: String, resourceServerPassword: String) {
        self.oAuthProviderURL = oAuthProviderURL
        self.resourceServerUsername = resourceServerUsername
        self.resourceServerPassword = resourceServerPassword
    }

    func introspect(accessToken: String, _ request: Request) async throws -> OAuthClientTokenIntrospectionResponse {

        let content = OAuthClientTokenIntrospectionRequest(token: accessToken)

        // Basic authentication credentials for request header
        let credentials = "\(resourceServerUsername):\(resourceServerPassword)".base64String()
        let headers = HTTPHeaders(dictionaryLiteral: ("Authorization", "Basic \(credentials)"))

        let response: ClientResponse
        do {
            response = try await request.client.post(
                URI(string: "\(oAuthProviderURL)/oauth/token_info"),
                headers: headers,
                content: content
            )
        } catch {
            throw OAuthClientErrors.openIDProviderServerError
        }

        guard response.status == .ok else {
            throw OAuthClientErrors.openIDProviderResponseError("\(response.status)")
        }

        do {
            return try response.content.decode(OAuthClientTokenIntrospectionResponse.self)
        } catch {
            throw OAuthClientErrors.dataDecodingError("OAuth_TokenIntrospectionResponse decoding failed.")
        }
    }
}
