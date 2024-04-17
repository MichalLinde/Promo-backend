import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    try app.register(collection: ProductController())
    try app.register(collection: ShopController() )
    try app.register(collection: UserController())
    
    app.post("user", ":userId", "shop", ":shopId") { req async throws -> HTTPStatus in
        guard let user = try await User.find(req.parameters.get("userId"), on: req.db), let shop = try await Shop.find(req.parameters.get("shopId"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        try await user.$shops.attach(shop, on: req.db)
        
        return .ok
    }
}
