//
//  File.swift
//  
//
//  Created by Michał Linde on 05/12/2023.
//

import Fluent
import Vapor

struct ProductController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let publicRoutes = routes.grouped("public", "products")
        let protected = routes.grouped(UserAuthenticator())
        let products = protected.grouped("products")
        products.get(use: index)
        products.post(use: create)
        
        products.group(":id") { product in
            product.get(use: show)
            product.put(use: update)
            product.delete(use: delete)
        }
        
        publicRoutes.get(use: getAll)
        publicRoutes.get(":id", use: getShopWithId)
    }
    
    func index(req: Request) async throws -> [Product] {
        try req.auth.require(User.self)
        return try await Product.query(on: req.db).all()
    }
    
    func create(req: Request) async throws -> Product {
        try req.auth.require(User.self)
        let product = try req.content.decode(Product.self)
        try await product.save(on: req.db)
        return product
    }
    
    func show(req: Request) async throws -> Product {
        try req.auth.require(User.self)
        guard let product = try await Product.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        return product
    }
    
    func update(req: Request) async throws -> Product {
        try req.auth.require(User.self)
        guard let product = try await Product.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        let updatedProduct = try req.content.decode(Product.self)
        product.name = updatedProduct.name
        product.description = updatedProduct.description
        product.price = updatedProduct.price
        product.image = updatedProduct.image
        product.amount = updatedProduct.amount
        product.category = updatedProduct.category
        product.$shop.id = updatedProduct.$shop.id
        product.discountPrice = updatedProduct.discountPrice
        product.discountDate = updatedProduct.discountDate
        product.maker = updatedProduct.maker
        try await product.save(on: req.db)
        return product
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        try req.auth.require(User.self)
        guard let product = try await Product.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await product.delete(on: req.db)
        return .ok
    }
    
    func getAll(req: Request) async throws -> [Product] {
        try await Product.query(on: req.db).all()
    }
    
    func getShopWithId(req: Request) async throws -> Product {
        guard let product = try await Product.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        return product
    }
}
