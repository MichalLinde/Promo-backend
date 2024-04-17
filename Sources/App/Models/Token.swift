//
//  File.swift
//  
//
//  Created by Michał Linde on 18/01/2024.
//

import Foundation
import Vapor
import Fluent

final class Token: Model, Content {
    static let schema = "tokens"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "userId")
    var user: User
    
    @Field(key: "value")
    var value: String
    
    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?
    
    init() {}
    
    init(id: UUID? = nil, userId: User.IDValue, token: String) {
        self.id = id
        self.$user.id = userId
        self.value = token
    }
}

extension Token: ModelTokenAuthenticatable {
    static let valueKey = \Token.$value
    static let userKey = \Token.$user
    
    var isValid: Bool {
        true
    }
}
