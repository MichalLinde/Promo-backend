//
//  File.swift
//  
//
//  Created by Michał Linde on 17/01/2024.
//

import Vapor
import Fluent

struct CreateUserShop: AsyncMigration {
    func prepare(on database: FluentKit.Database) async throws {
        try await database.schema("user+shop")
            .id()
            .field("userId", .uuid, .required, .references("users", "id"))
            .field("shopId", .uuid, .required, .references("shops", "id"))
            .create()
    }
    
    func revert(on database: FluentKit.Database) async throws {
        try await database.schema("user+shop").delete()
    }
}
