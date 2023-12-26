import Fluent
import Vapor
import VaporOAuth

struct SeedClient: AsyncMigration {

   func prepare(on database: Database) async throws {

      let client = MyClient(
         client_id: "1",
         redirect_uris: ["http://localhost:8089/callback"],
         client_secret: "password123",
         scopes: ["admin","openid"],
         confidential_client: true,
         first_party: true,
         grant_type: .authorization
      )

      return try await client.save(on: database)
   }

   func revert(on database: Database) async throws {

      try await MyClient.query(on: database)
         .filter(\.$client_id == "1")
         .delete()
   }

}



