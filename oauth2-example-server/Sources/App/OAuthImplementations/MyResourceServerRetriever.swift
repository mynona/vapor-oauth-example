import Vapor
import VaporOAuth
import Leaf
import Fluent

class MyResourceServerRetriever: ResourceServerRetriever {

   private let app: Application

   init(app: Application) {
      self.app = app
   }

   func getServer(_ username: String) async throws -> VaporOAuth.OAuthResourceServer? {

#if DEBUG
      print("\n-----------------------------")
      print("MyResourceServerRetriever().getServer()")
      print("-----------------------------")
      print("username: \(username)")
      print("-----------------------------")
#endif

      guard
         let server = try await MyResourceServer
            .query(on: app.db)
            .filter(\.$username == username)
            .first()
      else {
         return nil
      }

#if DEBUG
      print("\n-----------------------------")
      print("MyResourceServerRetriever().getServer()")
      print("-----------------------------")
      print("Database query: \(server)")
      print("-----------------------------")
#endif

      return OAuthResourceServer(username: server.username, password: server.password)
   }

}

