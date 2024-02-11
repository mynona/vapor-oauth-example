import Vapor

class OAuthCookieManager {
    // Constants for max age of different token types
    private let maxAgeAccessToken: Int = 60 * 2 // 2 minutes
    private let maxAgeRefreshToken: Int = 60 * 60 * 24 * 30 // 30 days
    private let maxAgeIDToken: Int = 60 * 60 // 1 hour

    // Environment dependent secure flag
    private func isSecure(environment: Environment) -> Bool {
        return environment == .production
    }

    // Create cookie based on token type and value
    func createCookie(withValue value: String, forToken tokenType: TokenType, environment: Environment) -> HTTPCookies.Value {
        let maxAge: Int
        let path: String?

        switch tokenType {
        case .AccessToken:
            maxAge = maxAgeAccessToken
            path = nil
        case .RefreshToken:
            maxAge = maxAgeRefreshToken
            path = nil
        case .IDToken:
            maxAge = maxAgeIDToken
            path = nil
        }

        return HTTPCookies.Value(
            string: value,
            expires: Date(timeIntervalSinceNow: TimeInterval(maxAge)),
            maxAge: maxAge,
            domain: nil,
            path: path,
            isSecure: isSecure(environment: environment),
            isHTTPOnly: true,
            sameSite: .lax
        )
    }

    // Add more methods for cookie management if needed
}
