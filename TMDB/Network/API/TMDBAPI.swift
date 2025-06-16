//
//  TMDBAPI.swift
//  TMDB
//
//  Created by Zsolt Molnár on 2024. 11. 24..
//

import Foundation

enum TMDBAPI {
    static let baseURL: String = "https://api.themoviedb.org/3"
    static func authorizationHeader(for token: String) -> [String: String] {
        ["Authorization": "Bearer \(token)"]
    }
    
    protocol Request: HTTP.Request {
        var path: String { get }
    }
}

extension TMDBAPI {
    enum TimeWindow: String {
        case day = "day"
        case week = "week"
    }
    
    struct MovieListItem: Codable {
        let id: Int
        let backdropPath: String?
        let title: String
        let originalTitle: String
        let overview: String
        let posterPath: String?
        let mediaType: String
        let adult: Bool
        let originalLanguage: String
        let genreIDs: [Int]
        let popularity: Float
        let releaseDate: String
        let video: Bool
        let voteAverage: Float
        let voteCount: Int

        enum CodingKeys: String, CodingKey {
            case id
            case backdropPath = "backdrop_path"
            case title
            case originalTitle = "original_title"
            case overview
            case posterPath = "poster_path"
            case mediaType = "media_type"
            case adult
            case originalLanguage = "original_language"
            case genreIDs = "genre_ids"
            case popularity
            case releaseDate = "release_date"
            case video
            case voteAverage = "vote_average"
            case voteCount = "vote_count"
        }
    }
    
    struct MovieWithDetails: Codable {
        let adult: Bool
        let backdropPath: String?
        let budget: Int?
        let genres: [Genre]
        let homepage: String
        let id: Int
        let imdbID: String?
        let originCountry: [String]
        let originalLanguage: String?
        let originalTitle: String?
        let overview: String
        let popularity: Double
        let posterPath: String
        let productionCompanies: [ProductionCompany]
        let productionCountries: [ProductionCountry]
        let releaseDate: String
        let revenue: Int
        let runtime: Int
        let spokenLanguages: [SpokenLanguage]
        let status: String
        let tagline: String
        let title: String
        let video: Bool
        let voteAverage: Double
        let voteCount: Int

        enum CodingKeys: String, CodingKey {
            case adult
            case backdropPath = "backdrop_path"
            case budget
            case genres
            case homepage
            case id
            case imdbID = "imdb_id"
            case originCountry = "origin_country"
            case originalLanguage = "original_language"
            case originalTitle = "original_title"
            case overview
            case popularity
            case posterPath = "poster_path"
            case productionCompanies = "production_companies"
            case productionCountries = "production_countries"
            case releaseDate = "release_date"
            case revenue
            case runtime
            case spokenLanguages = "spoken_languages"
            case status
            case tagline
            case title
            case video
            case voteAverage = "vote_average"
            case voteCount = "vote_count"
        }
    }

    struct Genre: Codable {
        let id: Int
        let name: String
    }

    struct ProductionCompany: Codable {
        let id: Int
        let logoPath: String?
        let name: String
        let originCountry: String

        enum CodingKeys: String, CodingKey {
            case id
            case logoPath = "logo_path"
            case name
            case originCountry = "origin_country"
        }
    }

    struct ProductionCountry: Codable {
        let iso31661: String
        let name: String

        enum CodingKeys: String, CodingKey {
            case iso31661 = "iso_3166_1"
            case name
        }
    }

    struct SpokenLanguage: Codable {
        let englishName: String
        let iso6391: String
        let name: String

        enum CodingKeys: String, CodingKey {
            case englishName = "english_name"
            case iso6391 = "iso_639_1"
            case name
        }
    }

    struct MovieList: Codable {
        let page: Int
        let results: [MovieListItem]
    }
}

extension TMDBAPI.Request {
    var url: String {
        TMDBAPI.baseURL + "/" + path
    }
}

extension TMDBAPI {
    enum Requests {
        struct GetTrendingMovies: Request {
            let timeWindow: TimeWindow
            var path: String { "trending/movie/\(timeWindow)" }
            var method: String { "GET" }
        }
        
        struct GetMovieDetails: Request {
            let id: Int
            var path: String { "movie/\(id)" }
            var method: String { "GET" }
        }
        
        struct GetRecommendedMovies: Request {
            let id: Int
            var path: String { "movie/\(id)/recommendations" }
            var method: String { "GET" }
        }
    }
}

extension TMDBAPI {
    enum Images {
        static let baseURL: String = "https://image.tmdb.org/t/p"
        enum Size: String {
            case w500
            case w780
            case w1280
            case original
        }
        static func url(for path: String, size: Size = .w500) -> URL {
            URL(string: baseURL + "/" + size.rawValue + "/" + path)!
        }
    }
}
