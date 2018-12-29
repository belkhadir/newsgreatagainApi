//
//  ArticleController.swift
//  App
//
//  Created by Belkahdir Anas on 11/24/18.
//

import Vapor
import Pagination
import FluentPostgreSQL

struct ArticleController:  RouteCollection {
    func boot(router: Router) throws {
        router.get("news", use: getNews)
        
        let tokenAuthenticationMiddleware = User.tokenAuthMiddleware()
        let authRoutes = router.grouped(tokenAuthenticationMiddleware)
        authRoutes.get(User.parameter,"news",use: filteredNews)
    }
    
    func getNews(_ req: Request) throws -> Future<Paginated<Article>> {
        return try Article.query(on: req).groupBy(\.title).paginate(for: req)
    }
    
    /*
        SELECT *
        FROM ARTICLE AS A1
        EXCEPT
        SELECT A2.ID
        FROM ARTICLE AS A2 WHERE A2.ID IN (
            SELECT articleID, userID
            from USERARTICLEPIVOT
            WHERE userID == id
        )
     */
    func filteredNews(_ req: Request) throws -> Future<Paginated<Article>> {
        let user = try req.requireAuthenticated(User.self)
        let id = try user.requireID()
        return try Article.query(on: req)
            .join(\Article.id, to: \UserArticlePivot.articleID)
            .filter(\UserArticlePivot.userID != id).paginate(for: req)
    }
    
}
    
