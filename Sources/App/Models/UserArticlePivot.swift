//
//  UserArticlePivot.swift
//  App
//
//  Created by Belkhadir Anas on 12/2/18.
//

import Vapor
import FluentPostgreSQL

final class UserArticlePivot: PostgreSQLUUIDPivot, ModifiablePivot {

    
    var id: UUID?

    var articleid: Article.ID
    var userid: User.ID
    var favorite: Bool? = nil
    var date: Date?
    
    typealias Left = Article
    typealias Right = User
    
    
    static var leftIDKey: WritableKeyPath<UserArticlePivot, Int> = \.articleid
    static var rightIDKey: WritableKeyPath<UserArticlePivot, Int> = \.userid

    init(_ left: Article, _ right: User) throws {
        self.articleid = try left.requireID()
        self.userid = try right.requireID()
        date = Date()
    }
    
    convenience init(_ left: Article, _ right: User, favorite: Bool = false) throws  {
        try self.init(left, right)
        self.favorite = favorite
    }
    
    
}

extension UserArticlePivot: Migration {
    
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.articleid, to: \Article.id, onDelete: .cascade)
            builder.reference(from: \.userid, to: \User.id, onDelete: .cascade)
        }
        
    }
    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.delete(self, on: connection)
    }
}
