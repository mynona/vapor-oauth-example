import Fluent
import Vapor

struct CreateAuthorizationCode: AsyncMigration {

   let schemaName: String  = MyAuthorizationCode.schema

   func prepare(on database: Database) async throws {

      try await database.schema(schemaName)
         .id()
         .field("code_id", .string)
         .field("client_id", .string)
         .field("redirect_uri", .string)
         .field("user_id", .string)
         .field("expiry_date", .datetime, .required)
         .field("scopes", .string)
         .create()
   }

   func revert(on database: Database) async throws {

      try await database.schema(schemaName)
         .delete()
   }

}

