//
//  MoviesCoordinator.swift
//  TMDB
//
//  Created by Zsolt Molnár on 2024. 11. 20..
//

import Foundation
import SwiftUI
import SwiftData

struct MoviesCoordinator: View {
    @State var movies: MovieList.State
    @StateObject var repository: MovieRepository
    @State private var selectedMovies: [Movie.Item] = []
    
    init() {
        let state = MovieList.State(movies: [])
        let network = HTTPClient()
        self._movies = State(initialValue: state)
        
        let modelContainer = try? ModelContainer(for: MovieList.State.self)
        self._repository = StateObject(wrappedValue: .init(state: state, network: network, modelContainer: modelContainer))
    }
    
    var body: some View {
        NavigationStack(path: $selectedMovies) {
            MovieListScreen(useCase: repository) { event in
                switch event {
                case .select(let movie):
                    selectedMovies.append(movie)
                }
            }
            .environment(movies)
            .navigationDestination(for: Movie.Item.self) { movie in
                MovieDetailScreen(useCase: repository, movie: movie) { event in
                    switch event {
                    case .select(let movie):
                        selectedMovies.append(movie)
                    case .loadFailed:
                        if let index = selectedMovies.lastIndex(of: movie) {
                            selectedMovies.remove(at: index)
                        }
                    }
                }
            }
        }
        
        .tint(.primary)
    }
}
