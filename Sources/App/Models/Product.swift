import Fluent
import Vapor

final class Product: Model, Content {
    static let schema = "products"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String
    
    @Field(key: "description")
    var description: String
    
    @Field(key: "price")
    var price: Double
    
    @Field(key: "image")
    var image: String
    
    @Field(key: "amount")
    var amount: Int
    
    @Field(key: "category")
    var category: String
    
    @Field(key: "maker")
    var maker: String
    
    @OptionalField(key: "discountPrice")
    var discountPrice: Double?
    
    @OptionalField(key: "discountDate")
    var discountDate: Date?
    
    @Parent(key: "shopId")
    var shop: Shop
    
    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updatedAt", on: .update)
    var updatedAt: Date?

    init() { }
    
    init(id: UUID? = nil, name: String, description: String, price: Double, image: String, amount: Int, category: String, maker: String, discountPrice: Double? = nil, discountDate: Date? = nil, createdAt: Date?, updatedAt: Date?, shopId: Shop.IDValue) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.image = image
        self.amount = amount
        self.category = category
        self.discountPrice = discountPrice
        self.discountDate = discountDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.$shop.id = shopId
        self.maker = maker
    }
}
