import Fluent
import Vapor

final class User: ModelAuthenticatable, Content {
    static var usernameKey = \User.$email
    
    static var passwordHashKey = \User.$password
    
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "email")
    var email: String
    
    @Field(key: "password")
    var password: String
    
    @Field(key: "role")
    var role: RoleType
    
    @Siblings(through: UserShop.self, from: \.$user, to: \.$shop)
    var shops: [Shop]
    
    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updatedAt", on: .update)
    var updatedAt: Date?

    init() { }
    
    init(id: UUID? = nil, email: String, password: String, role: String, createdAt: Date?, updatedAt: Date?) {
        self.id = id
        self.email = email
        self.password = password
        self.role = RoleType(rawValue: role) ?? .noType
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}

struct UserAuthenticator: AsyncBearerAuthenticator {
    typealias User = App.User
    
    func authenticate(bearer: BearerAuthorization, for request: Request) async throws {
        guard let userToken = try await Token.query(on: request.db)
            .join(User.self, on: \Token.$user.$id == \User.$id)
            .filter(\.$value == bearer.token)
            .first()
        else {
            throw Abort(.unauthorized)
        }
        
        let user = try userToken.joined(User.self)
        
        if bearer.token == userToken.value {
            request.auth.login(User(email: user.email, password: user.password, role: user.role.rawValue, createdAt: user.createdAt, updatedAt: user.updatedAt))
        }
    }
}

extension User {
    func generateToken() throws -> Token {
        try .init(userId: self.requireID(), token: [UInt8].random(count: 16).base64)
    }
}
