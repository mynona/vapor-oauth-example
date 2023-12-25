import Fluent

struct CreateIDToken: AsyncMigration {

   let schemaName: String  = MyIDToken.schema

   func prepare(on database: Database) async throws {

      try await database.schema(schemaName)
         .id()
         .field("token_string", .string)
         .field("issuer", .string)
         .field("subject", .string)
         .field("audience", .string)
         .field("expiration", .datetime)
         .field("issued_at", .datetime)
         .field("nonce", .string)
         .field("auth_time", .datetime)
         .create()
   }

   func revert(on database: Database) async throws {
      try await database.schema(schemaName)
         .delete()
   }
}
