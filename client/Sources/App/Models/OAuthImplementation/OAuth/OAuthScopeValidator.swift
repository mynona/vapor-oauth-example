import Vapor

class OAuthScopeValidator {

    /// Validate if the required scopes are included in the scopes granted by the OAuth provider.
    ///
    /// - Parameters:
    ///   - requiredScopes: A string of required scopes, separated by spaces.
    ///   - grantedScopes: A string of scopes granted by the OAuth provider, separated by spaces.
    /// - Returns: `true` if all required scopes are included in the granted scopes, `false` otherwise.
    func validateScope(requiredScopes: String, grantedScopes: String) -> Bool {
        let requiredScopesSet = Set(requiredScopes.split(separator: " ").map(String.init))
        let grantedScopesSet = Set(grantedScopes.split(separator: " ").map(String.init))

        return requiredScopesSet.isSubset(of: grantedScopesSet)
    }
}
