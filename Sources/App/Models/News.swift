//
//  News.swift
//  App
//
//  Created by xxx on 11/25/18.
//

import Foundation
import Vapor
import FluentPostgreSQL

struct News: Content, Decodable {
    let status: String?
    let totalResults: Int?
    let articles: [Article]
}
