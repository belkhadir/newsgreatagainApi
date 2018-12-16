//
//  Favorite.swift
//  App
//
//  Created by Belkahdir Anas on 11/24/18.
//

import FluentPostgreSQL

final class Favorite: PostgreSQLModel {
    var id: Int?
    let userID: User.ID
    let articleID: Article.ID
    let isFavorite: Bool
    
    init(userID: User.ID, articleID: Article.ID, isFavorite: Bool) {
        self.userID = userID
        self.articleID = articleID
        self.isFavorite = isFavorite
    }
    
}
