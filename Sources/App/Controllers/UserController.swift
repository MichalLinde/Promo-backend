//
//  File.swift
//  
//
//  Created by Michał Linde on 05/12/2023.
//

import Vapor
import Fluent

struct UserController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let protected = routes.grouped(UserAuthenticator())
        let users = protected.grouped("users")
        users.get("all", use: index)
        
        users.group(":id") { user in
            user.get(use: getUserWithId)
            user.put(use: updateUserWithId)
            user.delete(use: deleteUserWithId)
        }
        users.post("changePassword", ":newPassword", use: changePassword)
        
        routes.post("login", ":email", ":password") { req async throws -> Token in
            guard let email = req.parameters.get("email"), let password = req.parameters.get("password"), let userToCompare = try await User.query(on: req.db).filter(\.$email == email).first() else {
                throw Abort(.notFound)
            }
            if try userToCompare.verify(password: password) {
                let token = try userToCompare.generateToken()
                try await token.save(on: req.db)
                return token
            }
            throw Abort(.unauthorized)
        }
        
        routes.post("register") { req async throws -> Token in
            let user = try req.content.decode(User.self)
            let userToSave = user
            try userToSave.password = Bcrypt.hash(user.password)
            try await userToSave.save(on: req.db)
            let token = try userToSave.generateToken()
            try await token.save(on: req.db)
            return token
        }
    }
    
    func index(req: Request) async throws -> [User] {
        try req.auth.require(User.self)
        return try await User.query(on: req.db).all()
    }
    
    func getUserWithId(req: Request) async throws -> User {
        try req.auth.require(User.self)
        guard let userId = req.parameters.get("id"), let userUUID = UUID(userId), let user = try await User.query(on: req.db).with(\.$shops).filter(\.$id == userUUID).first() else {
            throw Abort(.notFound)
        }
        return user
    }
    
    func updateUserWithId(req: Request) async throws -> HTTPStatus {
        try req.auth.require(User.self)
        guard let user = try await User.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        let updatedUser = try req.content.decode(User.self)
        user.email = updatedUser.email
        user.password = updatedUser.password
        user.role = updatedUser.role
        try await user.save(on: req.db)
        return .ok
    }
    
    func deleteUserWithId(req: Request) async throws -> HTTPStatus {
        try req.auth.require(User.self)
        guard let user = try await User.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        if let userId = user.id {
            let tokens = try await Token.query(on: req.db).with(\.$user).filter(\.$user.$id == userId).all()
            for token in tokens {
                try await token.delete(on: req.db)
            }
        }
        try await user.$shops.detachAll(on: req.db)
        try await user.delete(on: req.db)
        return .ok
    }
    
    func changePassword(req: Request) async throws -> HTTPStatus {
        try req.auth.require(User.self)
        let user = try req.content.decode(User.self)
        guard let newPassword = req.parameters.get("newPassword"), let userToCompare = try await User.find(user.id, on: req.db) else {
            throw Abort(.badRequest)
        }
        
        if try userToCompare.verify(password: user.password) {
            userToCompare.password = try Bcrypt.hash(newPassword)
            try await userToCompare.update(on: req.db)
            return .ok
        }
        return .unauthorized
    }
}
