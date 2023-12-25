import Fluent
import Vapor

struct CreateAuthor: AsyncMigration {

   let schemaName: String  = Author.schema

   func prepare(on database: Database) async throws {

      try await database.schema(schemaName)
         .id()
         .field("first_name", .string)
         .field("last_name", .string)
         .field("username", .string, .required)
         .field("password", .string, .required)
         .field("scopes", .string, .required)
         .field("created_at", .datetime, .required)
         .field("updated_at", .datetime, .required)
         .unique(on: "username")
         .create()
   }


   func revert(on database: Database) async throws {

      try await database.schema(schemaName)
         .delete()
   }

}

