import Fluent
import FluentSQLiteDriver
import Vapor
import VaporOAuth
import Leaf
import JWTKit

public func configure(_ app: Application) throws {
   
   //      =============================================================
   //      Debugging
   //      =============================================================
   
   app.logger.logLevel = .notice
   
   //      =============================================================
   //      PORT
   //      =============================================================
   
   app.http.server.configuration.port = 8090
   
   //      =============================================================
   //      Database
   //      =============================================================
   
   app.databases.use(.sqlite(.file("local-db")), as: .sqlite)
   app.sessions.use(.fluent)
   
   //      =============================================================
   //      Migrations
   //      =============================================================
   
   // Create Tables
   app.migrations.add(SessionRecord.migration)
   app.migrations.add(CreateUser())
   app.migrations.add(CreateAuthorizationCode())
   app.migrations.add(CreateAccessToken())
   app.migrations.add(CreateRefreshToken())
   app.migrations.add(CreateIDToken())
   app.migrations.add(CreateResourceServer())
   app.migrations.add(CreateClient())
   
   // Seed with test data
   app.migrations.add(SeedUserJohnDoe())
   app.migrations.add(SeedUserJaneDoe())
   app.migrations.add(SeedResourceServer())
   app.migrations.add(SeedClient())
   
   try app.autoMigrate().wait()
   
   //      =============================================================
   //      OAuth / Session Middleware
   //      =============================================================
   
   app.middleware.use(app.sessions.middleware, at: .beginning)
   app.middleware.use(OAuthUserSessionAuthenticator())
   app.middleware.use(MyUser.sessionAuthenticator())

   //      =============================================================
   //      Leaf
   //      =============================================================
   
   app.views.use(.leaf)
   
   //      =============================================================
   //      OAuth configuration
   //      =============================================================

   let keyManagementService = MyKeyManagementService(app: app)

   app.lifecycle.use(
      OAuth2(
         codeManager: MyAuthorizationCodeManger(app: app),
         tokenManager: MyTokenManager(app: app),
         clientRetriever: MyClientRetriever(app: app),
         authorizeHandler: MyAuthorizationHandler(),
         userManager: MyUserManager(app: app),
         validScopes: nil, //["admin,openid"], value required if no clients defined
         resourceServerRetriever: MyResourceServerRetriever(app: app),
         oAuthHelper: .remote(
            tokenIntrospectionEndpoint: "",
            client: app.client,
            resourceServerUsername: "",
            resourceServerPassword: ""
         ),
         jwtSignerService: MyJWTSignerService(keyManagementService: keyManagementService),
         discoveryDocument: MyDiscoveryDocument(),
         keyManagementService: keyManagementService
      )
   )

   //      =============================================================
   //      JWT
   //      =============================================================

   guard
      let privateKey = keyManagementService.privateKey
   else{
      throw(Abort(.internalServerError, reason: "Private RSA Key could not be retrieved."))
   }

   app.jwt.signers.use(.rs256(key: privateKey))

   try Routes(app)
   
}
