//
//  Referal.swift
//  App
//
//  Created by Belkahdir Anas on 1/3/19.
//

import FluentPostgreSQL
import Vapor
import Pagination


final class Referal: PostgreSQLUUIDPivot, ModifiablePivot {
    var id: UUID?
    
    var userid: User.ID
    var inveted: User.ID
    
    var date: Date?
    
    typealias Left = User
    typealias Right = User
    
    static var leftIDKey: WritableKeyPath<Referal, Int> = \.userid
    static var rightIDKey: WritableKeyPath<Referal, Int> = \.inveted
    
    init(_ left: User, _ right: User) throws {
        guard let newUserId = left.id, let invitedID = right.id  else {
            throw Abort(HTTPStatus.notFound)
        }
        self.userid = newUserId
        self.inveted = invitedID
        date = Date()
    }
    
    
    
}

extension Referal: Parameter { }
extension Referal: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        // 1
        return Database.create(self, on: connection) { builder in
            // 2
            try addProperties(to: builder)
            // 3
            builder.reference(from: \.userid, to: \User.id, onDelete: .cascade)
            builder.reference(from: \.inveted, to: \User.id, onDelete: .cascade)
        }
    }
    
    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.delete(self, on: connection)
    }
}
