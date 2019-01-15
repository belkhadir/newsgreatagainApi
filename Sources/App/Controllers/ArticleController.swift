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
//        router.get("news", use: getNews)
        
        let tokenAuthenticationMiddleware = User.tokenAuthMiddleware()
        let authRoutes = router.grouped(tokenAuthenticationMiddleware)
        authRoutes.get("news", use: getNews)
        authRoutes.get(User.parameter,"news",use: filteredNews)
//        authRoutes.get(User.parameter, "filteredNewsV2", use: filteredNewsV2)
    }
    
    func getNews(_ req: Request) throws -> Future<Paginated<Article>> {
        return try Article.query(on: req).paginate(for: req)
    }
    
    func filteredNews(_ req: Request) throws -> Future<[Article]> {
        return try req.parameters.next(User.self).flatMap(to: [Article].self) { user in
            guard let id  = user.id else {
                throw Abort(HTTPStatus.notFound)
            }
            return req.withPooledConnection(to: .psql) { conn in
                return conn
                    .raw("Select * From \"Article\" as Ar where Ar.id not in (select UA.articleid From  \"Article_User\" as UA where UA.userid = \(id) group by UA.userid, UA.articleid)").all(decoding: Article.self)
            }
        }
    }
    
    func filteredNewsV2(_ req: Request) throws -> Future<Paginated<Article>> {
        return try req.parameters.next(User.self).flatMap(to: Paginated<Article>.self) { user in
            guard let id  = user.id else {
                throw Abort(HTTPStatus.notFound)
            }
            return try Article.query(on: req)
            .join(\UserArticlePivot.articleid, to: \Article.id)
//            .groupBy(\UserArticlePivot.articleid)
            .filter(\UserArticlePivot.userid, .notEqual, id)
            .paginate(for: req)
        }
    }
}
    
