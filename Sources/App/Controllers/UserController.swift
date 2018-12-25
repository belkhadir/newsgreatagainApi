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
        router.post("loginSocial", use: registerWithThird)
        
        let tokenAuthenticationMiddleware = User.tokenAuthMiddleware()
        let authRoutes = router.grouped(tokenAuthenticationMiddleware)
        authRoutes.get("logout", use: logout)
        authRoutes.post(User.parameter, "favorite", Article.parameter, use: addFavorite)
        authRoutes.get(User.parameter, "favorite", use: getFavorite)
    }
    
    func register(_ req: Request) throws -> Future<User.Public> {
        return try req.content.decode(User.self).flatMap { user in
            let hasher = try req.make(BCryptDigest.self)
            let passwordHashed = try hasher.hash(user.passowrd)
            let newUser = User(email: user.email, password: passwordHashed, fullName: user.fullName)
            return newUser.save(on: req).map { storedUser in
                return User.Public(id:  try storedUser.requireID(), email: storedUser.email)
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
                if try hasher.verify(user.passowrd, created: existingUser.passowrd) {
                    let tokenString = try URandom().generateData(count: 32).base32EncodedString()
                    let token = try Token(token: tokenString, userID: existingUser.requireID())
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
            return user.favorite.attach(article, on: req).transform(to: .created)
        })
    }
    
    func getFavorite(_ req: Request) throws -> Future<Paginated<Article>> {
        return try req.parameters.next(User.self).flatMap(to: Paginated<Article>.self) { user in
            try user.favorite.query(on: req).paginate(for: req)
        }
    }
    
    func getAllUser(_ req: Request) throws -> Future<[User]> {
        return User.query(on: req).all()
    }
    
    func registerWithThird(_ req: Request) throws -> Future<Token> {
        return  try req.content.decode(User.self).flatMap { userInfo in
            return User.query(on: req).filter(\.email == userInfo.email).first().flatMap { fetchedUser in
                if fetchedUser == nil {
                    let user = User(email: userInfo.email, password: "", fullName: userInfo.fullName)
                    _ = user.save(on: req)
                }
                return try self.login(req)
            }
        }
    }
}
