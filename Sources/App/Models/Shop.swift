import Fluent
import Vapor

final class Shop: Model, Content {
    static let schema = "shops"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String
    
    @Field(key: "description")
    var description: String
    
    @Field(key: "image")
    var image: String
    
    @Field(key: "locationCode")
    var locationCode: String
    
    @Children(for: \.$shop)
    var products: [Product]
    
    @Siblings(through: UserShop.self, from: \.$shop, to: \.$user)
    var users: [User]
    
    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updatedAt", on: .update)
    var updatedAt: Date?

    init() { }
    
    init(id: UUID? = nil, name: String, description: String, image: String, locationCode: String, createdAt: Date?, updatedAt: Date?) {
        self.id = id
        self.name = name
        self.description = description
        self.image = image
        self.locationCode = locationCode
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
