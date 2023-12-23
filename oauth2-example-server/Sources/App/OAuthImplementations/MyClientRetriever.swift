import Vapor
import VaporOAuth
import Leaf
import Fluent

final class MyClientRetriever: ClientRetriever {

   private let app: Application

   init(app: Application) {
      self.app = app
   }

   func getClient(clientID: String) async throws -> VaporOAuth.OAuthClient? {

#if DEBUG
      print("\n-----------------------------")
      print("MyClientRetriever().getClient()")
      print("-----------------------------")
      print("clientID: \(clientID)")
      print("-----------------------------")
#endif

      guard
         let client = try await MyClient
            .query(on: app.db)
            .filter(\.$client_id == clientID)
            .first()
      else {
         return nil
      }

#if DEBUG
      print("\n-----------------------------")
      print("MyClientRetriever().getClient()")
      print("-----------------------------")
      print("Database query: \(client)")
      print("-----------------------------")
#endif

      let oauthClient = OAuthClient(
         clientID: client.client_id,
         redirectURIs: client.redirect_uris,
         clientSecret: client.client_secret,
         validScopes: client.scopes,
         confidential: client.confidential_client,
         firstParty: client.first_party ?? true,
         allowedGrantType: client.grant_type
      )

#if DEBUG
      print("\n-----------------------------")
      print("MyClientRetriever().getClient()")
      print("-----------------------------")
      print("OAuthClient redirect: \(oauthClient.redirectURIs)")
      print("-----------------------------")
#endif

      return oauthClient

   }

}

