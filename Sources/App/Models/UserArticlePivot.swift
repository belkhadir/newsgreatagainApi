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
    
    
}

extension UserArticlePivot: Migration {
    
}
