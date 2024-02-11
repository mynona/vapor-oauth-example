import NIOSSL
import Fluent
import FluentSQLiteDriver
import Vapor
import VaporOAuth

// configures your application
public func configure(_ app: Application) async throws {

   //      =============================================================
   //      Application logger
   //      =============================================================

   app.logger.logLevel = .notice

   //      =============================================================
   //      Server Port
   //      =============================================================

   app.http.server.configuration.port = 8090

   //      =============================================================
   //      Database
   //      =============================================================

   app.databases.use(.sqlite(.file("db-oauth.sqlite")), as: .main)
   app.databases.use(.sqlite(.file("db-keys.sqlite")), as: .keyManagement)
   app.databases.default(to: .main)

   //      =============================================================
   //      Database migrations
   //      =============================================================

   app.migrations.add(CreateAccessToken(), to: .main)
   app.migrations.add(CreateAuthorizationCode(), to: .main)
   app.migrations.add(CreateRefreshToken(), to: .main)
   app.migrations.add(CreateResourceServer(), to: .main)
   app.migrations.add(CreateIDToken(), to: .main)
   app.migrations.add(CreateClient(), to: .main)
   app.migrations.add(CreateUser(), to: .main)
   app.migrations.add(CreateCryptoKey(), to: .keyManagement)
   app.migrations.add(CreateKeyOperationLog(), to: .keyManagement)

   //      =============================================================
   //      Database seeding
   //      =============================================================

   app.migrations.add(SeedClient(), to: .main)
   app.migrations.add(SeedResourceServer(), to: .main)
   app.migrations.add(SeedUserJohnDoe(), to: .main)
   app.migrations.add(SeedUserJaneDoe(), to: .main)
   app.migrations.add(SeedPrivateCryptoKey(), to: .keyManagement)
   app.migrations.add(SeedPublicCryptoKey(), to: .keyManagement)
   app.migrations.add(SessionRecord.migration)
   try await app.autoMigrate().get()

   //      =============================================================
   //      Sessions
   //      =============================================================

   app.sessions.configuration.cookieName = "oauth-session"
   app.sessions.use(.fluent(.main))

   //      =============================================================
   //      CORS
   //      =============================================================

    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .any(["http://auth.dewonderstruck.com:3000", "http://auth.dewonderstruck.com:8090", "http://auth.dewonderstruck.com:8089"]),
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin, .accessControlAllowHeaders, .init("X-CSRF-TOKEN")],
        allowCredentials: true
    )
    let cors = CORSMiddleware(configuration: corsConfiguration)
    app.middleware.use(cors, at: .beginning)

   //      =============================================================
   //      Middleware
   //      =============================================================

   app.middleware.use(app.sessions.middleware, at: .beginning)
   app.middleware.use(OAuthUserSessionAuthenticator())
   app.middleware.use(UserModel.sessionAuthenticator())

   //      =============================================================
   //      Leaf
   //      =============================================================

   app.views.use(.leaf)

   //      =============================================================
   //      OpenID Connect Server configuration
   //      =============================================================

   let cryptoKeysRepository = CryptoKeysRepository(database: app.db(.keyManagement))

   let keyManagementService = MyKeyManagementService(
      app: app,
      cryptoKeysRepository: cryptoKeysRepository
   )

   app.lifecycle.use(
      OAuth2(
         codeManager: AuthorizationCodeManger(app: app),
         tokenManager: TokenManager(app: app),
         clientRetriever: ClientRetriever(app: app),
         authorizeHandler: AuthorizationHandler(),
         userManager: UserManager(app: app),
         validScopes: nil, //["admin,openid"], value required if no clients defined
         resourceServerRetriever: ResourceServerRetriever(app: app),
         oAuthHelper: .remote(
            tokenIntrospectionEndpoint: "",
            client: app.client,
            resourceServerUsername: "",
            resourceServerPassword: ""
         ),
         jwtSignerService: JWTSignerService(
            keyManagementService: keyManagementService,
            cryptoKeysRepository: cryptoKeysRepository
         ),
         discoveryDocument: DiscoveryDocument(),
         keyManagementService: keyManagementService
      )
   )

   //      =============================================================
   //      Routes
   //      =============================================================

   try routes(app)

}

extension DatabaseID {
   static let main = DatabaseID(string: "main")
   static let keyManagement = DatabaseID(string: "keyManagement")
}
