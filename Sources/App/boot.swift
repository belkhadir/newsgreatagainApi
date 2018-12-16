import Vapor
import Jobs
import PostgreSQL

/// Called after your application has initialized.
public func boot(_ app: Application) throws {
    // your code here
    let connectionPool = try app.connectionPool(to: .psql)
    
    _ = connectionPool.withConnection { connection -> Future<Void> in
        
        Jobs.add(interval: .seconds(2 * 60)) {
            fetchFromInternet(connection)
        }
        
        Jobs.add(interval: .seconds(30*60)) {
            SharedPage.shared.page = 0
        }
        
        return app.eventLoop.future()
    }
}

func getNewsEveryMinute(minute: Double, completion: @escaping ()-> Void) {
    
    Jobs.add(interval: .seconds(minute * 60)) {
        completion()
    }
}

func fetchFromInternet(_ connection: PostgreSQLConnection) {
    SharedPage.shared.page = SharedPage.shared.page + 1
    let queries = [URLQueryItem(name: "pageSize", value: "100"), URLQueryItem(name: "page", value: "\(SharedPage.shared.page)"), .init(name: "country", value: "us"), .init(name: "apiKey", value: "7c5b1415d49543dba843f2d1d385a084")]
    
    request(for: News.self, host: "newsapi.org", path: "/v2/top-headlines", query: queries, method: HTTPMethod.get) { (result) in
        switch result {
        case .failure(let error): print(error)
        case .success(let value):
            for article in value.articles {
                _ = article.save(on: connection)
            }
        }
    }
}

