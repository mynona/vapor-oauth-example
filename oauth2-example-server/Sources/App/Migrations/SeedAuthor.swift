import Fluent
import Vapor

struct SeedAuthor: AsyncMigration {

   func prepare(on database: Database) async throws {

      let uuid = UUID(uuidString: "5c3afb78-3b44-11ec-8aa0-9c18a4eebeeb")
      let password = try Bcrypt.hash("password")

      let author =  Author(id: uuid,
                           first_name: "John",
                           last_name: "Doe",
                           username: "john_doe@something.com",
                           password: password,
                           scope: AuthorScope.ADMIN)

      return try await author.save(on: database)
   }

   func revert(on database: Database) async throws {

      try await Author.query(on: database)
         .filter(\.$username == "john_doe@something.com")
         .delete()
   }

}



