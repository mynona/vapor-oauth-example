import Vapor
import VaporOAuth
import Leaf
import Fluent

class MyClientRetriever: ClientRetriever {

   private let app: Application

   init(app: Application) {
      self.app = app
   }

   func getClient(clientID: String) async throws -> VaporOAuth.OAuthClient? {

#if DEBUG
      print("\n-----------------------------")
      print("MyResourceServerRetriever().getServer()")
      print("-----------------------------")
      print("clientID: \(clientID)")
      print("-----------------------------")
#endif


      return OAuthClient(
         clientID: "1",
         redirectURIs: ["http://localhost:8089/callback"],
         clientSecret: "password123",
         validScopes: ["admin"],
         confidential: true,
         firstParty: true,
         allowedGrantType: .authorization
      )

   }

}

