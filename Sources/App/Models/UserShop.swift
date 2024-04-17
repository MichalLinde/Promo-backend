//
//  File.swift
//  
//
//  Created by Michał Linde on 17/01/2024.
//

import Vapor
import Fluent

final class UserShop: Model {
    static let schema: String = "user+shop"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "userId")
    var user: User
    
    @Parent(key: "shopId")
    var shop: Shop
    
    init() {}
    
    init(id: UUID? = nil, userId: UUID, shopId: UUID) {
        self.id = id
        self.$user.id = userId
        self.$shop.id = shopId
    }
}
