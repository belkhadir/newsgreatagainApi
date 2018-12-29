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

    var articleID: Article.ID
    var userID: User.ID
    var favorite: Bool? = nil
    var date: Date?
    
    typealias Left = Article
    typealias Right = User
    
    
    static var leftIDKey: WritableKeyPath<UserArticlePivot, Int> = \.articleID
    static var rightIDKey: WritableKeyPath<UserArticlePivot, Int> = \.userID

    init(_ left: Article, _ right: User) throws {
        self.articleID = try left.requireID()
        self.userID = try right.requireID()
        date = Date()
    }
    
    convenience init(_ left: Article, _ right: User, favorite: Bool = false) throws  {
        try self.init(left, right)
        self.favorite = favorite
    }
    
    
}

extension UserArticlePivot: Migration {
    
    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.delete(self, on: connection)
    }
}
