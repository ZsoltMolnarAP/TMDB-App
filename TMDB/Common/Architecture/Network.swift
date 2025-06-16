//
//  Network.swift
//  TMDB
//
//  Created by Zsolt Molnár on 2024. 11. 23..
//

import Foundation

enum HTTP {
    protocol Request {
        var url: String { get }
        var method: String { get }
    }
    
    struct Response<T: Decodable> {
        let code: Int
        let body: T
    }
    
    enum Error: Swift.Error {
        case invalidURL(String)
        case networkError(Swift.Error)
        case badResponse(Int, Data)
        case invalidData
        case invalidJSON(Swift.Error)
    }
    
    protocol Client {
        func request<T: Decodable>(_ request: Request, headers: [String: String]) async throws(Error) -> Response<T>
    }
}
