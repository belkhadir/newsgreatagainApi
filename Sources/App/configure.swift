import FluentPostgreSQL
import Vapor
import Authentication
import Leaf


/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentPostgreSQLProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    try services.register(AuthenticationProvider())
    
    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a SQLite database
    var databases = DatabasesConfig()
    databases.enableLogging(on: .psql)
    let databaseConfig = PostgreSQLDatabaseConfig(hostname: "127.0.0.1", port: 5432, username: "newsgreatagain", database: "newsgreatagain", password: "password", transport: .cleartext)
    let database = PostgreSQLDatabase(config: databaseConfig)

    databases.add(database: database, as: .psql)
    services.register(databases)
    
    var commands = CommandConfig.default()
    commands.useFluentCommands()
    services.register(commands)
    try services.register(LeafProvider())
    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: Article.self, database: .psql)
    
    migrations.add(model: Token.self, database: .psql)
    migrations.add(model: UserArticlePivot.self, database: .psql)
    migrations.add(model: Referal.self, database: .psql)
    migrations.add(model: Order.self, database: .psql)
    migrations.add(model: ContactMe.self, database: .psql)
    services.register(migrations)

    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
}
