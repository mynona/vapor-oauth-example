import Vapor

struct Router: RouteCollection {

   func boot(routes: RoutesBuilder) throws {
      routes.get("client-login", use: Controller().clientLogin)
      routes.get("callback", use: Controller().callback)
      routes.get("introspection-test", use: Controller().protectedResource)
      routes.get("userinfo-test", use: Controller().userInfo)
      routes.get("client-logout", use: Controller().clientLogout)
      routes.get("unauthorized", use: Controller().unauthorized)
      routes.get(use: Controller().home)
   }
   
}
