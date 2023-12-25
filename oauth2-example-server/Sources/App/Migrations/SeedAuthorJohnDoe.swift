import Fluent
import Vapor

struct SeedAuthorJohnDoe: AsyncMigration {

   func prepare(on database: Database) async throws {

      let uuid = UUID(uuidString: "5c3afb78-3b44-11ec-8aa0-9c18a4eebeeb")
      let password = try Bcrypt.hash("password")

      let author = Author(
         id: uuid,
         username: "john_doe@something.com",
         password: password,
         givenName: "John",
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
         scopes: ["admin","openid"]
      )

      return try await author.save(on: database)
   }

   func revert(on database: Database) async throws {

      try await Author
         .query(on: database)
         .filter(\.$username == "john_doe@something.com")
         .delete()
   }

}



