//
//  File.swift
//  
//
//  Created by Michał Linde on 05/12/2023.
//

import Vapor
import Fluent

struct ShopController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let publicRoutes = routes.grouped("public", "shops")
        
        let protected = routes.grouped(UserAuthenticator())
        let shops = protected.grouped("shops")
        shops.get(use: index)
        shops.post(use: create)
        
        shops.group(":id") { shop in
            shop.get(use: show)
            shop.put(use: update)
            shop.delete(use: delete)
        }
        
        shops.post(":shopId", "assignUser", ":userId", use: assignUserWithId)
        shops.get("forUser", ":userId", use: getShopsForUser)
        
        publicRoutes.get(use: getAll)
        publicRoutes.get(":id", use: getShopWithId)
    }
    
    func getAll(req: Request) async throws -> [Shop] {
        try await Shop.query(on: req.db).with(\.$products).all()
    }
    
    func index(req: Request) async throws -> [Shop] {
        try req.auth.require(User.self)
        return try await Shop.query(on: req.db).all()
    }
    
    func create(req: Request) async throws -> Shop {
        try req.auth.require(User.self)
        let shop = try req.content.decode(Shop.self)
        try await shop.save(on: req.db)
        if let user = try await User.query(on: req.db).filter(\.$role == RoleType.admin).first() {
            req.logger.info("TEST")
            try await shop.$users.attach(user, on: req.db)
        }
        return shop
    }
    
    func show(req: Request) async throws -> Shop {
        try req.auth.require(User.self)
        guard let shopId = req.parameters.get("id"), let shopUUID = UUID(shopId), let shop = try await Shop.query(on: req.db).with(\.$products).with(\.$users).filter(\.$id == shopUUID).first() else {
            throw Abort(.notFound)
        }
        return shop
    }
    
    func update(req: Request) async throws -> Shop {
        try req.auth.require(User.self)
        guard let shop = try await Shop.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        let updatedShop = try req.content.decode(Shop.self)
        shop.name = updatedShop.name
        shop.description = updatedShop.description
        shop.image = updatedShop.image
        try await shop.save(on: req.db)
        return shop
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        try req.auth.require(User.self)
        guard let shopId = req.parameters.get("id"), let shopUUID = UUID(shopId), let shop = try await Shop.query(on: req.db).with(\.$products).filter(\.$id == shopUUID).first() else {
            throw Abort(.notFound)
        }
        for product in shop.products {
            try await product.delete(on: req.db)
        }
        try await shop.$users.detachAll(on: req.db)
        try await shop.delete(on: req.db)
        return .ok
    }
    
    func assignUserWithId(req: Request) async throws -> HTTPStatus {
        try req.auth.require(User.self)
        req.logger.info("It's in")
        guard let shop = try await Shop.find(req.parameters.get("shopId"), on: req.db), let user = try await User.find(req.parameters.get("userId"), on: req.db)
        else {
            throw Abort(.notFound)
        }
        try await shop.$users.attach(user, on: req.db)
        return .ok
    }
    
    func getShopWithId(req: Request) async throws -> Shop {
        guard let shopId = req.parameters.get("id"), let shopUUID = UUID(shopId), let shop = try await Shop.query(on: req.db).with(\.$products).filter(\.$id == shopUUID).first() else {
            throw Abort(.notFound)
        }
        return shop
    }
    
    func getShopsForUser(req: Request) async throws -> [Shop] {
        try req.auth.require(User.self)
        guard let userId = req.parameters.get("userId"), let userUUID = UUID(userId) else {
            throw Abort(.notFound)
        }
        let shops = try await Shop.query(on: req.db).with(\.$users).all()
        let filteredShops = shops.filter({ $0.users.contains { user in
            user.id == userUUID
        }})
        return filteredShops
    }
}
