//
//  ContactMe.swift
//  App
//
//  Created by Belkhadir Anas on 1/22/19.
//
import FluentPostgreSQL
import Vapor
import Authentication

final class ContactMe: PostgreSQLModel  {
    var id: Int?
    
    var email: String
    var fullName: String?
    var message: String?
    init(email: String, fullName: String, message: String) {
        self.email = email
        self.fullName = fullName
        self.message = message
    }
}

extension ContactMe: Content {}
extension ContactMe: Migration {}
extension ContactMe: Parameter {}
