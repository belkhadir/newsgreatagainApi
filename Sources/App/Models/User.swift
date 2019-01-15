//
//  User.swift
//  App
//
//  Created by Belkhadir Anas on 11/24/18.
//

import FluentPostgreSQL
import Vapor
import Authentication

final class User: PostgreSQLModel {
    var id: Int?
    // TODO: Rename the password when the app is live
    var password: String
    var email: String
    var fullName: String
    
    init(email: String, password: String, fullName: String) {
        self.email = email
        self.password = password
        self.fullName = fullName
    }
}

extension User: Content {}
extension User: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
            // 1
            return Database.create(self, on: connection) { builder in
                // 2
                try addProperties(to: builder)
                // 3
                builder.unique(on: \.email)
                
            }
    }
    
    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.delete(self, on: connection)
    }
}
extension User: TokenAuthenticatable {
    typealias TokenType = Token
}
extension User: Parameter {}
extension User {
    struct Public: Content {
        let id: Int
        let email: String
        let fullName: String
    }
    
    var favorite: Siblings<User, Article, UserArticlePivot> {
        return siblings()
    }
    
    var orders: Children<User, Order> {
        return children(\.userid)
    }
    
//    var invite: Siblings<User, User, Referal> {
//        return siblings(\uS, <#T##relatedPivotField: WritableKeyPath<Pivot, ID>##WritableKeyPath<Pivot, ID>#>)
//    }
}


