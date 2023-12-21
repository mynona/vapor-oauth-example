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
   app.migrations.add(CreateAuthor())
   app.migrations.add(CreateAccessToken())
   app.migrations.add(CreateRefreshToken())
   app.migrations.add(SessionRecord.migration)

   // Seed
   app.migrations.add(SeedAuthor())
   
   try app.autoMigrate().wait()
   
   //      =============================================================
   //      OAuth / Session Middleware
   //      =============================================================
   
   app.middleware.use(app.sessions.middleware, at: .beginning)
   app.middleware.use(Author.sessionAuthenticator())
   app.middleware.use(OAuthUserSessionAuthenticator())


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
   
   let someOAuthClient = OAuthClient(
      clientID: "1",
      redirectURIs: ["http://localhost:8089/callback"],
      clientSecret: "password123",
      validScopes: ["admin"],
      allowedGrantType: .authorization
   )

   app.lifecycle.use(
      OAuth2(
         codeManager: LiveCodeManger(),
         tokenManager: LiveTokenManager(app: app),
         clientRetriever: StaticClientRetriever(clients: [someOAuthClient]),
         authorizeHandler: LiveAuthorizeHandler(),
         validScopes: ["admin"],
         resourceServerRetriever: LiveResourceServerRetriever(),
         oAuthHelper: .remote(
            tokenIntrospectionEndpoint: "token_info",
            client: app.client,
            resourceServerUsername: "test",
            resourceServerPassword: "test"
         )
         
      )
   )
   
   try Routes(app)
}






