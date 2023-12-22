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
      print("OAuthResourceServerRetriever().getServer()")
      print("-----------------------------")
      print("username: \(username)")
      print("-----------------------------")
#endif

      let refreshToken = "31E8A7F3-F268-408C-85AB-27C205AEA479"
      let temp = try await MyRefreshToken.query(on: app.db)
         .filter(\.$tokenString == refreshToken)
         .first()

      print(temp)


      return OAuthResourceServer(username: "test", password: "test")
   }

}

