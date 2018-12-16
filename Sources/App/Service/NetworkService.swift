//
//  NetworkService.swift
//  WeatherApp
//
//  Created by xxx on 11/2/18.
//  Copyright © 2018 Belkhadir. All rights reserved.
//


import Foundation

struct ForHTTPHeaderField {
    static let Accept = "Accept"
    static let ContentType = "Content-Type"
    static let keyApi = "x-api-key"
}



enum RequestError: Error {
    case novalidURL(String?)
}

enum HTTPMethod: String{
    case post = "POST"
    case get = "GET"
}

let baseURL = "https://api.darksky.net/forecast/"

func request<T: Decodable>(for type: T.Type,
                           host: String,
                           path: String,
                           query: [URLQueryItem],
                           method: HTTPMethod,
                           completion: @escaping (Result<T, DataResponseError>) -> Void) {
    
    var compenents = URLComponents()
    compenents.scheme = "https"
    compenents.host = host //"api.coinmarketcap.com"

    compenents.path = path
    
    compenents.queryItems = query
    
    guard let url = compenents.url else {
        completion(Result.failure(DataResponseError.decoding))
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
//    request.addValue("", forHTTPHeaderField: ForHTTPHeaderField.keyApi)
    request.addValue("application/json", forHTTPHeaderField: ForHTTPHeaderField.ContentType)
    request.addValue("application/json", forHTTPHeaderField: ForHTTPHeaderField .Accept)
        
        
    let config = URLSessionConfiguration.default
    let session = URLSession(configuration: config)
    let task = session.dataTask(with: request) { (responseData, response, responseError) in
            
        guard let jsonD = responseData else {
            completion(Result.failure(DataResponseError.decoding))
            return
        }
        
        do {
            let responseData = try JSONDecoder().decode(type.self, from: jsonD)
            print(responseData)
            completion(Result.success(responseData))
        } catch let error{
            debugPrint(error)
            
            
        }
    }
    task.resume()
    
}

func convertToDictionary(data: Data) -> [String: Any]? {
    
    do {
        return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
    } catch {
        print(error.localizedDescription)
    }
    
    return nil
}
