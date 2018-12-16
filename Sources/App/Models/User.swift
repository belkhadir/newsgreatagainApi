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
    var passowrd: String
    var email: String
    init(email: String, password: String) {
        self.email = email
        self.passowrd = password
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
}
extension User: TokenAuthenticatable {
    typealias TokenType = Token
}
extension User: Parameter {}
extension User {
    struct Public: Content {
        let id: Int
        let email: String
    }
    
    var favorite: Siblings<User, Article, UserArticlePivot> {
        return siblings()
    }
}
