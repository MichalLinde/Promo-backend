import Foundation
import Fluent

struct CreateToken: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("tokens")
            .id()
            .field("userId", .uuid, .required, .references("users", "id"))
            .field("value", .string, .required)
            .unique(on: "value")
            .field("createdAt", .datetime, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("tokens").delete()
    }
}
