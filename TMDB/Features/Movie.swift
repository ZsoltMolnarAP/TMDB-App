//
//  Movie.swift
//  TMDB
//
//  Created by Zsolt Molnár on 2024. 11. 20..
//

import Foundation

enum Movie {
    typealias Id = Int
    struct Item: Codable, Hashable, Identifiable {
        let id: Id
        let title: String
        let overview: String
        let rating: Float
        let releaseDate: Date?
        let poster: ImageSource
        let backdrop: ImageSource?
    }

    struct Detailed: Hashable, Identifiable {
        let item: Item
        let details: Details
        
        var id: Id { item.id }
    }
    
    struct Genre: Identifiable, Hashable {
        let id: Int
        let name: String
    }
    
    struct ProductionCompany: Identifiable, Hashable {
        let id: Int
        let logo: ImageSource
        let name: String
    }
    
    struct Details: Hashable {
        let tagline: String
        let runtimeMinutes: Duration
        let genres: [Genre]
        let companies: [ProductionCompany]
    }
}

extension Movie.Details {
    static var empty: Self {
        .init(tagline: "", runtimeMinutes: .seconds(0), genres: [], companies: [])
    }
}
