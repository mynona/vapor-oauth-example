import Fluent
import Vapor

struct CreateAuthor: AsyncMigration {

   let schemaName: String  = Author.schema

   func prepare(on database: Database) async throws {

      // Enum must be created as database.enum
      // and is logged via the table _fluent_enums in the database
      let scope = try await database.enum("scope")
         .case("admin")
         .case("editor")
         .case("viewer")
         .create()

      try await database.schema(schemaName)
         .id()
         .field("first_name", .string)
         .field("last_name", .string)
         .field("username", .string, .required)
         .field("password", .string, .required)
         .field("scope", scope, .required) // database enum
         .field("created_at", .datetime, .required)
         .field("updated_at", .datetime)
         .unique(on: "username")
         .create()
   }


   func revert(on database: Database) async throws {

      try await database.schema(schemaName)
         .delete()
   }

}

