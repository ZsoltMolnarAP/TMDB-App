//
//  MovieListScreen.swift
//  TMDB
//
//  Created by Zsolt Molnár on 2024. 11. 20..
//

import Foundation
import SwiftUI
import SwiftData

enum MovieList {
    @Model
    class State {
        var movies: [Movie.Item] = []
        
        init(movies: [Movie.Item]) {
            self.movies = movies
        }
    }

    protocol UseCase: AnyObject {
        func fetch() async throws
    }
    
    enum Event {
        case select(Movie.Item)
    }
}

struct MovieListScreen: View {
    @Environment(MovieList.State.self) var state

    let useCase: MovieList.UseCase
    let eventHandler: (MovieList.Event) -> Void
    
    @State private var loading: Bool = false
    @State private var error: Bool = false
    
    init(useCase: MovieList.UseCase, eventHandler: @escaping (MovieList.Event) -> Void) {
        self.useCase = useCase
        self.eventHandler = eventHandler
    }
    
    var body: some View {
        MovieListView(movies: state.movies,
                      eventHandler: eventHandler)
            .redacted(reason: isPreloading ? .placeholder : [])
            .task {
                await fetch()
            }
            .alert("Oops somethign went wrong", isPresented: $error) {
                Button("OK", role: .cancel) {
                    Task {
                        await fetch()
                    }
                }
            }
            .navigationTitle("Trending Movies")
    }
    
    private func fetch() async {
        guard state.movies.isEmpty else { return }
        do {
            loading = true
            try await useCase.fetch()
        } catch {
            print(error)
            self.error = true
        }
        loading = false
    }
    
    private var isPreloading: Bool {
        state.movies.isEmpty && loading
    }
}

struct MovieListView: View {
    let movies: [Movie.Item]
    let eventHandler: (MovieList.Event) -> Void
    let columns = [ GridItem(.adaptive(minimum: 150)) ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(movies) { movie in
                    Button {
                        eventHandler(.select(movie))
                    } label: {
                        MovieCellView(movie: movie)
                    }
                    .foregroundStyle(.primary)
                }
            }
            .padding()
        }
        .background(Color(UIColor.secondarySystemBackground))
    }
}

struct MovieCellView: View {
    let movie: Movie.Item
    
    var body: some View {
        VStack(alignment: .leading) {
            ImageView(imageSource: movie.poster, placeholder: Image(systemName: "movieclapper.fill"))
                .posterFormat()
            VStack(alignment: .leading, spacing: 4) {
                RatingView(number: movie.rating)
                Text(movie.title)
                    .lineLimit(1)
                    .font(.headline)
                    .padding(.bottom, 6)
            }
            .frame(height: 55)
            .padding(.horizontal, 8)
        }
        .background(Color.secondary.opacity(0.2))
        .cornerRadius(12)
        .background(RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.systemBackground))
                        .shadow(radius: 3, x: 0, y: 3))
        .transition(.opacity.animation(.default))
    }
}


private extension Movie {
    static var mockItems: [Movie.Item] {
        [
            .init(id: 1,
                  title: "Movie title",
                  overview: "Movie description long text thingy lore ipsum",
                  rating: 5.6,
                  releaseDate: Date(),
                  poster: .local("movie_poster"),
                  backdrop: .local("movie_backdrop")),
            .init(id: 2,
                  title: "Movie title",
                  overview: "Movie description long text thingy lore ipsum",
                  rating: 5.6,
                  releaseDate: Date(),
                  poster: .local("movie_poster"),
                  backdrop: .local("movie_backdrop")),
            .init(id: 3,
                  title: "Movie title",
                  overview: "Movie description long text thingy lore ipsum",
                  rating: 5.6,
                  releaseDate: Date(),
                  poster: .local("movie_poster"),
                  backdrop: .local("movie_backdrop")),
            .init(id: 4,
                  title: "Movie title",
                  overview: "Movie description long text thingy lore ipsum",
                  rating: 5.6,
                  releaseDate: Date(),
                  poster: .local("movie_poster"),
                  backdrop: .local("movie_backdrop")),
            .init(id: 5,
                  title: "Movie title",
                  overview: "Movie description long text thingy lore ipsum",
                  rating: 5.6,
                  releaseDate: Date(),
                  poster: .local("movie_poster"),
                  backdrop: .local("movie_backdrop")),
            .init(id: 6,
                  title: "Movie title",
                  overview: "Movie description long text thingy lore ipsum",
                  rating: 5.6,
                  releaseDate: Date(),
                  poster: .local("movie_poster"),
                  backdrop: .local("movie_backdrop"))
        ]
    }
}

#Preview {
    NavigationStack {
        MovieListView(movies: Movie.Item.mock(count: 6)) { _ in }
            .navigationTitle("Treding Movies")
    }
}
