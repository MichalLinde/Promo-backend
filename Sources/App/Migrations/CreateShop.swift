import Fluent

struct CreateShop: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("shops")
            .id()
            .field("name", .string, .required)
            .field("description", .string, .required)
            .field("image", .string, .required)
            .field("locationCode", .string, .required)
            .field("createdAt", .datetime, .required)
            .field("updatedAt", .datetime, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("shops").delete()
    }
}
