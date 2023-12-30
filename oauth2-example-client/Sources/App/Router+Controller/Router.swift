import Vapor

struct Router: RouteCollection {

   func boot(routes: RoutesBuilder) throws {
      routes.get("client-login", use: Controller().clientLogin)
      routes.get("callback", use: Controller().callback)
      routes.get("introspection-test", use: Controller().introspectionTest)
      routes.get("refresh", use: Controller().refreshToken)
      routes.get("client-logout", use: Controller().clientLogout)
      routes.get(use: Controller().home)
   }
   
}
