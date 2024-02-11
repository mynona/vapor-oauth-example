/// OAuthClient errors
///
/// - Tag: OAuthClientErrors
///
public enum OAuthClientErrors: Error {
    
    /// Request did not include expected token
    case tokenCookieNotFound(TokenType)
    
    /// OpenID Provider time out
    case openIDProviderServerError
    
    /// OpenID Provider response status was not 200 OK
    case openIDProviderResponseError(String)
    
    /// Data could not be decoded
    case dataDecodingError(String)
    
    /// JWK for provided key identifier (kid) was not found in JWK Set
    case jwkKeyNotFound
    
    /// Validation failed
    case validationError(String)
    
    /// Public RSA Key generation failed
    case publicKeyGenerationFailed
    
    /// Authorization Grant Flow parameter not returned from OpenID Provider
    case authorizationFlowParameterMissing(String)
    
    /// Authorization Grant Flow code could not be exchanged for tokens
    case authorizationFlowFailed
    
    case tokenNotFound
    
    case invalidCodeVerifier
}
