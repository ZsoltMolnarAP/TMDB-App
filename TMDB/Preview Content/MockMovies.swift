//
//  MockMovies.swift
//  TMDB
//
//  Created by Zsolt Molnár on 2024. 11. 25..
//

import Foundation

extension Movie.Item {
    static func mock(count: Int) -> [Self] {
        return Array(1...count).map { mock(id: $0) }
    }
    
    static func mock(id: Int) -> Self {
        .init(id: id,
              title: "Movie title long",
              overview: "Movie description long text thingy lore ipsum",
              rating: 5.6,
              releaseDate: Date(),
              poster: .local("movie_poster"),
              backdrop: .local("movie_backdrop"))
    }
}

extension Movie.Detailed {
    static func mock(id: Int) -> Self {
        let item = Movie.Item.mock(id: id)
        let details = Movie.Details(
            tagline: "Fancy stuff",
            runtimeMinutes: .seconds(111 * 60),
            genres: [
                .init(id: 1, name: "SciFi"),
                .init(id: 2, name: "Horror"),
                .init(id: 3, name: "Action")
            ], companies: [
                .init(id: 1, logo: .local("movie_company"), name: "Skydance"),
                .init(id: 1, logo: .local("movie_company"), name: "Skydance"),
                .init(id: 1, logo: .local("movie_company"), name: "Skydance")
        ])
        return .init(item: item, details: details)
    }
}
