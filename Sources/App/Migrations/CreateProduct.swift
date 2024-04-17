//
//  File.swift
//  
//
//  Created by Michał Linde on 05/12/2023.
//

import Foundation
import Fluent

struct CreateProduct: AsyncMigration {
    
    func prepare(on database: FluentKit.Database) async throws {
        try await database.schema("products")
            .id()
            .field("name", .string, .required)
            .field("description", .string, .required)
            .field("price", .double, .required)
            .field("image", .string, .required)
            .field("amount", .int, .required)
            .field("category", .string, .required)
            .field("maker", .string, .required)
            .field("discountPrice", .double)
            .field("discountDate", .datetime)
            .field("shopId", .uuid, .required, .references("shops", "id"))
            .field("createdAt", .datetime, .required)
            .field("updatedAt", .datetime, .required)
            .create()
    }
    
    func revert(on database: FluentKit.Database) async throws {
        try await database.schema("products").delete()
    }
}
