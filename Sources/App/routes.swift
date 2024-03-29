import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {

    let userController = UserController()
    try router.register(collection: userController)
    
    let articleController = ArticleController()
    try router.register(collection: articleController)
    
    let websiteController = WebsiteController()
    try router.register(collection: websiteController)
    
}
