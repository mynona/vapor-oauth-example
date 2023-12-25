import Fluent
import Vapor

struct SeedAuthorJaneDoe: AsyncMigration {
   
   func prepare(on database: Database) async throws {
      
      let uuid = UUID(uuidString: "8c3afb78-3b44-11ec-8aa0-9c18a4eebeeb")
      let password = try Bcrypt.hash("password")

      let author = Author(
         id: uuid,
         username: "jane_doe@something.com",
         password: password,
         givenName: "Jane",
         familyName: "Doe",
         middleName: nil,
         nickname: nil,
         profile: nil,
         picture: nil,
         website: nil,
         gender: nil,
         birthdate: nil,
         zoneinfo: nil,
         locale: nil,
         phoneNumber: nil,
         scopes: ["viewer","openid","something","something"]
      )

      return try await author.save(on: database)
   }
   
   func revert(on database: Database) async throws {
      
      try await Author
         .query(on: database)
         .filter(\.$username == "jane_doe@something.com")
         .delete()
   }
   
}



