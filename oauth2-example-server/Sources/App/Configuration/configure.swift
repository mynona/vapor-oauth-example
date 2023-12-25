import Fluent
import FluentSQLiteDriver
import Vapor
import VaporOAuth
import Leaf

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
   app.migrations.add(CreateAuthor())
   app.migrations.add(CreateAuthorizationCode())
   app.migrations.add(CreateAccessToken())
   app.migrations.add(CreateRefreshToken())
   app.migrations.add(CreateIDToken())
   app.migrations.add(CreateResourceServer())
   app.migrations.add(CreateClient())

   // Seed with test data
   app.migrations.add(SeedAuthorJohnDoe())
   app.migrations.add(SeedAuthorJaneDoe())
   app.migrations.add(SeedResourceServer())
   app.migrations.add(SeedClient())

   try app.autoMigrate().wait()

   //      =============================================================
   //      OAuth / Session Middleware
   //      =============================================================

   app.middleware.use(app.sessions.middleware, at: .beginning)
   app.middleware.use(OAuthUserSessionAuthenticator())
   app.middleware.use(Author.sessionAuthenticator())

   //      =============================================================
   //      JWT
   //      =============================================================

   app.jwt.signers.use(.hs256(key: "test"))

   //      =============================================================
   //      Leaf
   //      =============================================================

   app.views.use(.leaf)

   //      =============================================================
   //      OAuth configuration
   //      =============================================================

   app.lifecycle.use(
      OAuth2(
         codeManager: MyCodeManger(app: app),
         tokenManager: MyTokenManager(app: app),
         clientRetriever: MyClientRetriever(app: app),
         authorizeHandler: MyAuthorizationHandler(),
         userManager: MyUserManager(app: app),
         validScopes: nil, //["admin,openid"], value required if no clients
         resourceServerRetriever: MyResourceServerRetriever(app: app),
         oAuthHelper: .remote(
            tokenIntrospectionEndpoint: "",
            client: app.client,
            resourceServerUsername: "",
            resourceServerPassword: ""
         )
      )
   )


   try Routes(app)

}
