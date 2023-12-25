import Fluent

struct CreateRefreshToken: AsyncMigration {
   
   let schemaName: String  = MyRefreshToken.schema
   
   func prepare(on database: Database) async throws {
      
      try await database.schema(schemaName)
         .id()
         .field("token_string", .string, .required)
         .field("client_id", .string, .required)
         .field("user_id", .string, .required)
         .field("scopes", .string, .required)
         .field("expiry_time", .datetime)
         .create()
   }
   
   func revert(on database: Database) async throws {
      try await database.schema(schemaName)
         .delete()
   }
}
