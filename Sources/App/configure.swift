import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("localhost") ?? "localhost",
        port: Environment.get("5352").flatMap(Int.init(_:)) ?? 5352,
        username: Environment.get("postgres") ?? "postgres",
        password: Environment.get("") ?? "",
        database: Environment.get("promodb") ?? "promodb",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)
    
    app.http.server.configuration.hostname = "0.0.0.0"
    app.http.server.configuration.port = 8080
    
    app.migrations.add(CreateUser())
    app.migrations.add(CreateShop())
    app.migrations.add(CreateProduct())
    app.migrations.add(CreateUserShop())
    app.migrations.add(CreateToken())

    // register routes
    try routes(app)
}
