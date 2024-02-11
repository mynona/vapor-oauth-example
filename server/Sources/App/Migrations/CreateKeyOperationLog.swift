import Fluent

struct CreateKeyOperationLog: AsyncMigration {
   
   func prepare(on database: Database) async throws {
      
      let key_operation = try await database.enum("key_operation")
         .case("create")
         .case("rotate")
         .case("deprecate")
         .create()
      
      try await database.schema(KeyOperationLog.schema)
         .id()
         .field("key_id", .uuid, .required, .references(CryptoKey.schema, "id"))
         .field("operation", key_operation, .required) // database_enum
         .field("timestamp", .datetime, .required)
         .create()
   }
   
   func revert(on database: Database) async throws {
      try await database.schema(KeyOperationLog.schema).delete()
   }
   
}
