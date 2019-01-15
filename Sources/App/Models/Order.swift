//
//  Order.swift
//  App
//
//  Created by Belkhadir Anas on 1/4/19.
//

import FluentPostgreSQL
import Vapor
import Pagination

final class Order: PostgreSQLUUIDModel {
    var id: UUID?
    var userid: User.ID
    var name: String
    var date: Date
    
    init(userid: User.ID, name: String) {
        self.userid = userid
        self.name = name
        self.date = Date()
    }
}

extension Order {
    var user: Parent<Order, User> {
        return parent(\.userid)
    }
}

extension Order: Content {}

extension Order: Parameter { }
extension Order: Migration {
    
    
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        // 1
        return Database.create(self, on: connection) { builder in
            // 2
            try addProperties(to: builder)
            // 3
            builder.reference(from: \.userid, to: \User.id)
        }
    }
    
    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.delete(self, on: connection)
    }
}
