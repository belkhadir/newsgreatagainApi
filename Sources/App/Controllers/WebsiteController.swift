

import Vapor
import Leaf
import Fluent

struct WebsiteController: RouteCollection {
    func boot(router: Router) throws {
        router.get(use: indexHandler)
        router.get("contact", use: redirectContactMe)
        router.post(CreatContactMe.self, use: createContackMe)
    }
    
    func indexHandler(_ req: Request) throws -> Future<View> {
        let context = IndexContext(title: "News Great Again.")
        return try req.view().render("index", context)
    }
    
    func createContackMe(_ req: Request, data: CreatContactMe) throws ->  Future<HTTPResponse> {
        guard let email = data.email else {
            throw Abort(.internalServerError)
        }
        
        guard let fullName = data.fullName else {
            throw Abort(.internalServerError)
        }
        
        guard let message = data.message else {
            throw Abort(.internalServerError)
        }
        
        let contact = ContactMe(email: email, fullName: fullName, message: message)
        
        return contact.save(on: req).transform(to: HTTPResponse(status: .ok))
    }
    
    func redirectContactMe(_ req: Request) throws -> Future<View> {
        return try req.view().render("createContactMe")
    }
}

struct IndexContext: Encodable {
    let title: String
}

struct CreatContactMe: Content {
    let email: String?
    let fullName: String?
    let message: String?
}
