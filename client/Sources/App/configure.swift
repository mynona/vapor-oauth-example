import NIOSSL
import Vapor
import Fluent
import FluentSQLiteDriver
import Leaf

// configures your application
public func configure(_ app: Application) async throws {

   //      =============================================================
   //      Logger
   //      =============================================================

   app.logger.logLevel = .notice

   //      =============================================================
   //      Port
   //      =============================================================

   app.http.server.configuration.port = 8089

   //      =============================================================
   //      Renderer
   //      =============================================================

    app.views.use(.leaf)

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
   //      Database
   //      =============================================================

   app.databases.use(.sqlite(.file("db-client.sqlite")), as: .sqlite)
   app.sessions.use(.fluent)

   //      =============================================================
   //      Sessions
   //      =============================================================

   app.sessions.configuration.cookieName = "client-session"
   let sessionsMiddleware = app.sessions.middleware
   app.middleware.use(sessionsMiddleware)
   app.sessions.use(.fluent(.sqlite))

   //      =============================================================
   //      Database seeding
   //      =============================================================

   app.migrations.add(SessionRecord.migration)
   try await app.autoMigrate().get()

   //      =============================================================
   //      Routes
   //      =============================================================

   try routes(app)

}
