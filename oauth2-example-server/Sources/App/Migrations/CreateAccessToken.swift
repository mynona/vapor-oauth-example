import Fluent

struct CreateAccessToken: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("access_tokens")
            .id()
            .field("token_string", .string, .required)
            .field("client_id", .string, .required)
            .field("user_id", .string, .required)
            .field("scopes", .string, .required)
            .field("expiry_time", .datetime, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("access_tokens").delete()
    }
}