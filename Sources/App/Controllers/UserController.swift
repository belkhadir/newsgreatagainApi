//
//  UserController.swift
//  App
//
//  Created by Belkhadir Anas on 11/24/18.
//

import Vapor
import Crypto
import Random
import FluentPostgreSQL
import Pagination

final class UserController: RouteCollection {
    func boot(router: Router) throws {
        router.post("register", use: register)
        router.post("login", use: login)
    
        let tokenAuthenticationMiddleware = User.tokenAuthMiddleware()
        let authRoutes = router.grouped(tokenAuthenticationMiddleware)
        authRoutes.get("logout", use: logout)
        authRoutes.post(User.parameter, "addfavorite", Article.parameter,use: addFavorite)
        authRoutes.post(User.parameter, "unfavorite", Article.parameter ,use: addUnFavorite)
        authRoutes.get(User.parameter, "favorite", use: getFavorite)
        authRoutes.post(User.parameter, "referal", User.parameter, use: addReferal)
        authRoutes.get(User.parameter, "orders",  use: getOrders)
    }
    
    func register(_ req: Request) throws -> Future<User.Public> {
        return try req.content.decode(User.self).flatMap { user in
            let hasher = try req.make(BCryptDigest.self)
            let passwordHashed = try hasher.hash(user.password)
            guard let fullName = user.fullName else {
                throw Abort(HTTPStatus.notFound)
            }
            let newUser = User(email: user.email, password: passwordHashed, fullName: fullName)
            return newUser.save(on: req).map { storedUser in
                guard let fullName = storedUser.fullName else {
                    throw Abort(HTTPStatus.notFound)
                }
                return User.Public(id:  try storedUser.requireID(), email: storedUser.email, fullName: fullName)
            }
        }
    }
    
    func login(_ req: Request) throws -> Future<Token> {
        return try req.content.decode(User.self).flatMap { user in
            return User.query(on: req).filter(\.email == user.email).first().flatMap { fetchedUser in
                guard let existingUser = fetchedUser else {
                    throw Abort(HTTPStatus.notFound)
                }
                let hasher = try req.make(BCryptDigest.self)
                if try hasher.verify(user.password, created: existingUser.password) {
                    let tokenString = try URandom().generateData(count: 32).base32EncodedString()
                    guard let fullName = existingUser.fullName else {
                        throw Abort(HTTPStatus.notFound)
                    }
                    let token = try Token(token: tokenString, userID: existingUser.requireID(), fullName: fullName, email: existingUser.email)
                    return token.save(on: req)
                }else {
                    throw Abort(HTTPStatus.unauthorized)
                }
            }
        }
    }
    
    func logout(_ req: Request) throws -> Future<HTTPResponse> {
        let user = try req.requireAuthenticated(User.self)
        return try Token
            .query(on: req)
            .filter(\Token.userID, .equal, user.requireID())
            .delete()
            .transform(to: HTTPResponse(status: .ok))
        
    }
    
    func addFavorite(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(to: HTTPStatus.self, req.parameters.next(User.self), req.parameters.next(Article.self), { user, article in
            let favorite = try UserArticlePivot(article, user, favorite: true)
            return favorite.save(on: req).transform(to: .created)
//            return user.favorite.attach(article, on: req).transform(to: .created)
        })
    }
    
    func addUnFavorite(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(to: HTTPStatus.self, req.parameters.next(User.self), req.parameters.next(Article.self), { user, article in
            let unfavorite = try UserArticlePivot(article, user, favorite: false)
            return unfavorite.save(on: req).transform(to: .created)
        })
    }
    
    
//    func getFavorite(_ req: Request) throws -> Future<[Article]> {
//        return try req.parameters.next(User.self).flatMap(to: [Article].self) { user in
//            guard let id  = user.id else {
//                throw Abort(HTTPStatus.notFound)
//            }
//            return req.withPooledConnection(to: .psql) { conn in
//                return conn
//                    .raw("Select * From \"Article\" as Ar where Ar.id in (select UA.articleid From  \"Article_User\" as UA where UA.userid = \(id) and UA.favorite = \(true) group by UA.userid, UA.articleid)").all(decoding: Article.self)
//            }
//        }
//    }
    
    func getFavorite(_ req: Request) throws -> Future<Paginated<Article>> {
        return try req.parameters.next(User.self).flatMap(to: Paginated<Article>.self) { user in
            guard let id  = user.id else {
                throw Abort(HTTPStatus.notFound)
            }
            return try Article.query(on: req)
            .join(\UserArticlePivot.articleid, to: \Article.id)
            .filter(\UserArticlePivot.favorite == true)
            .filter(\UserArticlePivot.userid == id)
            .paginate(for: req)
        }
    }

    
    func getAllUser(_ req: Request) throws -> Future<[User]> {
        return User.query(on: req).all()
    }
    
    
    func addReferal(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(to: HTTPStatus.self,
                          req.parameters.next(User.self),
                          req.parameters.next(User.self), { user, invited in
                            let referal = try Referal(user, invited)
                            return  referal.save(on: req).transform(to: .created)
        })
    }

    func getOrders(_ req: Request) throws -> Future<[Order]> {
        return try req.parameters.next(User.self).flatMap(to: [Order].self) { (user) in
            return try user.orders.query(on: req).all()
        }
    }
    
//    func countReferal(_ req: Request) throws -> Future<Int> {
//        return try User.query(on: req).join(\Referal., to: <#T##KeyPath<C, D>#>)
//    }
}
