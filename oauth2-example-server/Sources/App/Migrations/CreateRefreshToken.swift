import Fluent

struct CreateRefreshToken: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("refresh_tokens")
            .id()
            .field("token_string", .string, .required)
            .field("client_id", .string, .required)
            .field("user_id", .string, .required)
            .field("scopes", .string, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("refresh_tokens").delete()
    }
}