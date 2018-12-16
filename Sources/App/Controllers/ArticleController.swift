//
//  ArticleController.swift
//  App
//
//  Created by Belkahdir Anas on 11/24/18.
//

import Vapor
import Pagination
import Jobs
import FluentPostgreSQL

struct ArticleController:  RouteCollection {
    func boot(router: Router) throws {
//        router.get("remotenews", use: getMoreNews)
        router.get("news", use: getNews)
    }
    
    
    // TODO : 1- order article by date and get the lates one
    //        2- check the date of the article by the current date
    //           if it's the latest date is upper than the current date by 15 hour added
    //           then fetch from the server the articles via newsAPI
    //        3- save the article fetched from the api
    
    

    
//    func getMoreNews(_ req: Request) throws -> Future<[Article]> {
//        ArticleController.page = ArticleController.page + 1
//        return try req.client()
//            .get("https://newsapi.org/v2/top-headlines?pageSize=100&page=\(ArticleController.page)&country=us&apiKey=7c5b1415d49543dba843f2d1d385a084")
//            .map(to: [Article].self) { response in
//                let news = try response.content.syncDecode(News.self)
//                self.saveNews(req, articles: news.articles)
//                return news.articles
//        }
//    }
    
    func getNews(_ req: Request) throws -> Future<Paginated<Article>> {
        return try Article.query(on: req).paginate(for: req)
    }
    
//    func saveNews(_ req: Request, articles: [Article]) {
//        _ = articles.map { article -> Future<Article>? in
//            return article.save(on: req)
//        }
//    }
    
    

}
    
