//
//  HTTPClient.swift
//  TMDB
//
//  Created by Zsolt Molnár on 2024. 11. 24..
//

import Foundation

class HTTPClient: HTTP.Client {
    let defaultHeaders: [String: String] = ["accept": "application/json"]
    
    func request<T: Decodable>(_ request: HTTP.Request, headers: [String: String]) async throws(HTTP.Error) -> HTTP.Response<T> {
        guard let url = URL(string: request.url) else {
            throw .invalidURL(request.url)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.uppercased()
        urlRequest.timeoutInterval = 10
        urlRequest.allHTTPHeaderFields = defaultHeaders.merging(headers) { (_, new) in new }
        
        print("Request: \(urlRequest.url?.absoluteString ?? "")")
        
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: urlRequest)
        } catch let error {
            throw .networkError(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw .badResponse(0, data)
        }
        
        let parsedResponse: HTTP.Response<T>
        switch httpResponse.statusCode {
            case 200..<300:
            do {
                let body = try JSONDecoder().decode(T.self, from: data)
                parsedResponse = .init(code: httpResponse.statusCode, body: body)
            } catch let error {
                throw .invalidJSON(error)
            }
        default:
            throw .badResponse(httpResponse.statusCode, data)
        }
        
        return parsedResponse
    }
}
