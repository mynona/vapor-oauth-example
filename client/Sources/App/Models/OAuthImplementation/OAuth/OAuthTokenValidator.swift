import Vapor
import JWTKit

class OAuthTokenValidator {
    private let oAuthProviderURL: String

    init(oAuthProviderURL: String) {
        self.oAuthProviderURL = oAuthProviderURL
    }

    func validateJWT(forTokens tokenSet: [TokenType: String], _ request: Request) async throws -> Bool {
        let response: ClientResponse
        do {
            response = try await request.client.get("\(self.oAuthProviderURL)/.well-known/jwks.json")
        } catch {
            throw OAuthClientErrors.openIDProviderServerError
        }

        guard response.status == .ok else {
            throw OAuthClientErrors.openIDProviderResponseError("\(response.status)")
        }

        let jwkSet: JWKS
        do {
            jwkSet = try response.content.decode(JWKS.self)
        } catch {
            throw OAuthClientErrors.validationError("JWK Set decoding failed.")
        }

        let signers = JWTSigners()
        try signers.use(jwks: jwkSet)

        for (type, token) in tokenSet {
            do {
                switch type {
                case .AccessToken:
                    _ = try signers.verify(token, as: PayloadAccessToken.self)
                case .RefreshToken:
                    _ = try signers.verify(token, as: PayloadRefreshToken.self)
                case .IDToken:
                    let payload = try signers.verify(token, as: PayloadIDToken.self)
                    // Additional payload checks can be performed here
                }
            } catch {
                throw OAuthClientErrors.validationError("JWT Signature and Payload check of \(type) failed.")
            }
        }

        return true
    }
}
