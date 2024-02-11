import Vapor

public class OAuthClient {
    let cookieManager: OAuthCookieManager
    let tokenExchanger: OAuthTokenExchanger
    let tokenRefresher: OAuthTokenRefresher
    let tokenValidator: OAuthTokenValidator
    let introspector: OAuthIntrospector
    let authorizer: OAuthAuthorizer
    let logoutHandler: OAuthLogoutHandler
    let userInfoFetcher: OAuthUserInfoFetcher
    let scopeValidator: OAuthScopeValidator
    
    init(
      oAuthProviderURL: String,
      callbackURL: String,
      clientID: String,
      clientSecret: String,
      resourceServerUsername: String,
      resourceServerPassword: String,
      serverSessionCookieName: String,
      stateVerifier: String,
      codeVerifier: String,
      nonce: String
    ) {
        self.cookieManager = OAuthCookieManager()
        self.tokenExchanger = OAuthTokenExchanger(oAuthProviderURL: oAuthProviderURL, callbackURL: callbackURL, clientID: clientID, clientSecret: clientSecret, codeVerifier: codeVerifier)
        self.tokenRefresher = OAuthTokenRefresher(oAuthProviderURL: oAuthProviderURL, clientID: clientID, clientSecret: clientSecret, resourceServerUsername: resourceServerUsername, resourceServerPassword: resourceServerPassword)
        self.tokenValidator = OAuthTokenValidator(oAuthProviderURL: oAuthProviderURL)
        self.introspector = OAuthIntrospector(oAuthProviderURL: oAuthProviderURL, resourceServerUsername: resourceServerUsername, resourceServerPassword: resourceServerPassword)
        self.authorizer = OAuthAuthorizer(oAuthProviderURL: oAuthProviderURL, callbackURL: callbackURL, clientID: clientID, stateVerifier: stateVerifier, codeVerifier: codeVerifier, nonce: nonce)
        self.logoutHandler = OAuthLogoutHandler(oAuthProviderURL: oAuthProviderURL, serverSessionCookieName: serverSessionCookieName)
        self.userInfoFetcher = OAuthUserInfoFetcher(oAuthProviderURL: oAuthProviderURL)
        self.scopeValidator = OAuthScopeValidator()
    }
    
    func exchangeAuthorizationCodeForTokens(_ request: Request) async throws -> (accessToken: String?, refreshToken: String?, idToken: String?) {
        return try await tokenExchanger.exchangeAuthorizationCodeForTokens(request)
    }
    
    func exchangeRefreshTokenForNewTokens(_ request: Request) async throws -> OAuthClientRefreshTokenResponse {
        return try await tokenRefresher.exchangeRefreshTokenForNewTokens(request)
    }
    
    func validateJWT(forTokens tokenSet: [TokenType: String], _ request: Request) async throws -> Bool {
        return try await tokenValidator.validateJWT(forTokens: tokenSet, request)
    }
    
    func introspect(accessToken: String, _ request: Request) async throws -> OAuthClientTokenIntrospectionResponse {
        return try await introspector.introspect(accessToken: accessToken, request)
    }
    
    func requestAuthorizationCode(_ request: Request) async throws -> Response {
        return try await authorizer.requestAuthorizationCode(request)
    }
    
   func logout(_ request: Request, redirectURL: String) async throws -> Response {
        return try await logoutHandler.logout(request, redirectURL: redirectURL)
    }
    
    func userInfo(_ request: Request) async throws -> OAuthClientUserInfoResponse {
        return try await userInfoFetcher.userInfo(request)
    }
    
    func validateScope(requiredScopes: String, retrievedScopes: String) -> Bool {
        return scopeValidator.validateScope(requiredScopes: requiredScopes, grantedScopes: retrievedScopes)
    }
    
    func validateAccessToken(_ request: Request) async throws -> Bool {
        guard let accessToken = request.headers.bearerAuthorization?.token else {
            throw OAuthClientErrors.tokenNotFound
        }
        // If you have an introspection endpoint
         let introspectionResponse = try await introspector.introspect(accessToken: accessToken, request)
        return introspectionResponse.active
    }
}
