//
//  Token.swift
//  App
//
//  Created by Belkhadir Anas on 11/24/18.
//

import Foundation
import FluentPostgreSQL
import Authentication

final class Token: PostgreSQLModel {
    var id: Int?
    var token: String
    var userID: User.ID
    
    init(token: String, userID: User.ID) {
        self.token = token
        self.userID = userID
    }
    
}


extension Token {
    var user: Parent<Token, User> {
        return parent(\.userID)
    }
}

extension Token: BearerAuthenticatable {
    static var tokenKey: WritableKeyPath<Token, String> {
        return \Token.token
    }
}

extension Token: Authentication.Token {
    typealias UserType = User
    typealias UserIDType = User.ID
    
    static var userIDKey: WritableKeyPath<Token, User.ID> {
        return \Token.userID
    }
}

extension Token: Migration {
    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.delete(self, on: connection)
    }
}
extension Token: Content {}

