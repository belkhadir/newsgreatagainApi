//
//  Article.swift
//  App
//
//  Created by Belkahdir Anas on 11/24/18.
//

import FluentPostgreSQL
import Vapor
import Pagination

final class Article: PostgreSQLModel {
    var id: Int?
    
    var author: String?
    let title: String?
    let description: String?
    let url: String?
    var urlToImage: String?
    let publishedAt: String?
    var content: String?
 
    
}

extension Article {
    var date: Date? {
        guard let string = publishedAt else {
            return nil
        }
        return Date(rfc1123: string)
    }
}

extension Article: Content {}
extension Article: Paginatable {}
extension Article: Parameter { }
extension Article: Migration {}
