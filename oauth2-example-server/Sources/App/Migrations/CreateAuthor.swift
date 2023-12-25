import Fluent
import Vapor

struct CreateAuthor: AsyncMigration {

   let schemaName: String  = Author.schema

   func prepare(on database: Database) async throws {

      try await database.schema(schemaName)
         .id()
         .field("username", .string, .required)
         .field("password", .string, .required)
         .field("given_name", .string)
         .field("family_name", .string)
         .field("middle_name", .string)
         .field("nickname", .string)
         .field("profile", .string)
         .field("picture", .string)
         .field("website", .string)
         .field("gender", .string)
         .field("birthdate", .string)
         .field("zoneinfo", .string)
         .field("locale", .string)
         .field("phone_number", .string)
         .field("created_at", .datetime, .required)
         .field("updated_at", .datetime, .required)
         .field("scopes", .string, .required)
         .unique(on: "username")
         .create()
   }


   func revert(on database: Database) async throws {

      try await database.schema(schemaName)
         .delete()
   }

}

