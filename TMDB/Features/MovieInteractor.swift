//
//  MovieInteractor.swift
//  TMDB
//
//  Created by Zsolt Molnár on 2024. 11. 24..
//

import Foundation
import SwiftData

@MainActor
class MovieInteractor: ObservableObject {
    private let state: MovieList.State
    private let network: HTTP.Client
    private let modelContainer: ModelContainer?
    private var modelContext: ModelContext? = nil
    
    init(state: MovieList.State, network: HTTP.Client, modelContainer: ModelContainer?) {
        self.state = state
        self.network = network
        
        self.modelContainer = modelContainer
        if let modelContainer {
            let context = ModelContext(modelContainer)
            self.modelContext = context
            
            do {
                let query = FetchDescriptor<MovieList.State>()
                if let loadedState = try context.fetch(query).first {
                    self.state.movies = loadedState.movies
                }
            } catch {
                print("Failed to load state: \(error)")
            }
        }
    }
    
    private let token = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI0ZWY3MDJkNjM3NzA0NTY0MzA4MDhmYjA4ZTM5M2U3OCIsIm5iZiI6MTczMjExOTEzOC42OTg3NDEsInN1YiI6IjY3M2UwNzQwYWIyZTI1MGY1NzBmN2M3YyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.zoigqVCiXor_hU2zjEEDVPDoSmQzj587Q9p3iWVt0Tg"
    
    private static let releaseDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    enum MappingError: Swift.Error {
        case missingField(String)
    }
}

extension MovieInteractor: MovieList.UseCase {
    func fetch() async throws {
        let movieList: HTTP.Response<TMDBAPI.MovieList> = try await network.request(
            TMDBAPI.Requests.GetTrendingMovies(timeWindow: .day),
            headers: TMDBAPI.authorizationHeader(for: token))
        let movies: [Movie.Item] = movieList.body.results // Gracefully ignore paging :)
            .compactMap { try? MovieInteractor.map(item: $0) }
        self.state.movies = movies
        
        if let modelContext {
            try modelContext.delete(model: MovieList.State.self)
            modelContext.insert(self.state)
            try modelContext.save()
        }
    }
}

extension MovieInteractor: MovieDetail.UseCase {
    private static func map(item: TMDBAPI.MovieListItem) throws -> Movie.Item {
        guard let posterPath = item.posterPath else {
            throw MappingError.missingField("posterPath")
        }
        return .init(id: item.id,
              title: item.title,
              overview: item.overview,
              rating: item.voteAverage,
              releaseDate: Self.releaseDateFormatter.date(from: item.releaseDate),
              poster: .remote(TMDBAPI.Images.url(for: posterPath)),
              backdrop: item.backdropPath.map { .remote(TMDBAPI.Images.url(for: $0, size: .original)) } ?? nil
         )
    }
    
    func details(for movie: Movie.Item) async throws -> Movie.Detailed {
        let response: HTTP.Response<TMDBAPI.MovieWithDetails> = try await network.request(
            TMDBAPI.Requests.GetMovieDetails(id: movie.id),
            headers: TMDBAPI.authorizationHeader(for: token))
        let details = response.body
        let movieDetailed = Movie.Detailed(
            item: movie,
            details: .init(
                tagline: details.tagline,
                runtimeMinutes: .seconds(details.runtime * 60),
                genres: details.genres.map { .init(id: $0.id, name: $0.name) },
                companies: details.productionCompanies.compactMap {
                    guard let logoPath = $0.logoPath else { return nil }
                    return .init(id: $0.id, logo: .remote(TMDBAPI.Images.url(for: logoPath)), name: $0.name)
                }
            )
        )
        return movieDetailed
    }
    
    func recommended(for movieId: Movie.Id) async throws -> [Movie.Item] {
        let response: HTTP.Response<TMDBAPI.MovieList> = try await network.request(
            TMDBAPI.Requests.GetRecommendedMovies(id: movieId),
            headers: TMDBAPI.authorizationHeader(for: token))
        
        let movies: [Movie.Item] = response.body.results // Gracefully ignore paging :)
            .compactMap { try? MovieInteractor.map(item: $0) }
        return movies
    }
}
