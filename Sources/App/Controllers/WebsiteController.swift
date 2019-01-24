

import Vapor
import Leaf
import Fluent

struct WebsiteController: RouteCollection {
    func boot(router: Router) throws {
        router.get(use: indexHandler)
        router.get("contact", use: redirectContactMe)
        router.post(CreatContactMe.self, at: "/", use: createContackMe)
    }
    
    func indexHandler(_ req: Request) throws -> Future<View> {
        let context = IndexContext(title: "News Great Again.")
        return try req.view().render("base", context)
    }
    
    func createContackMe(_ req: Request, data: CreatContactMe) throws ->  Future<HTTPResponse> {

        let contact = ContactMe(email: data.email, fullName: data.fullName, message: data.message)
        
        return contact.save(on: req).transform(to: HTTPResponse(status: .ok))
    }
    
    func redirectContactMe(_ req: Request) throws -> Future<View> {
        let context = IndexContext(title: "Contact US.")
        return try req.view().render("/", context)
    }
}

struct IndexContext: Encodable {
    let title: String
}

struct CreatContactMe: Content {
    let email: String
    let fullName: String
    let message: String
}
