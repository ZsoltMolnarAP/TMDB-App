//
//  MovieDetailScreen.swift
//  TMDB
//
//  Created by Zsolt Molnár on 2024. 11. 21..
//

import Foundation
import SwiftUI

enum MovieDetail {
    protocol UseCase: AnyObject {
        func details(for movie: Movie.Item) async throws -> Movie.Detailed
        func recommended(for movie: Movie.Id) async throws -> [Movie.Item]
    }
    
    enum Event {
        case select(Movie.Item)
        case loadFailed
    }
}

struct MovieDetailScreen: View {
    let useCase: MovieDetail.UseCase
    let movie: Movie.Item
    let eventHandler: (MovieDetail.Event) -> Void
    @State var details: Movie.Detailed?
    @State var recommended: [Movie.Item] = []
    
    var body: some View {
        Group {
            if let details {
                MovieDetailView(movie: details, recommended: recommended, eventHandler: eventHandler)
            } else {
                MovieDetailView(movie: placeholder(movie: movie), recommended: recommended, eventHandler: eventHandler)
                    .redacted(reason: .placeholder)
            }
        }
        .task {
            do {
                details = try await useCase.details(for: movie)
            } catch {
                print(error)
                eventHandler(.loadFailed)
            }
            do {
                recommended = try await useCase.recommended(for: movie.id)
            } catch {
                print(error)
            }
        }
    }
    
    func placeholder(movie: Movie.Item) -> Movie.Detailed {
        .init(item: movie, details: .init(tagline: "",
                                          runtimeMinutes: .seconds(0),
                                          genres: [],
                                          companies: []))
    }
}

struct MovieDetailView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    let movie: Movie.Detailed
    let recommended: [Movie.Item]
    let eventHandler: (MovieDetail.Event) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading) {
                            ImageView(imageSource: movie.item.poster, placeholder: Image(systemName: "movieclapper.fill"))
                                .posterFormat()
                                .frame(minWidth: 50,
                                       maxWidth: geometry.size.width <= 50 ? 50 :
                                        (horizontalSizeClass == .compact
                                       ? geometry.size.width / 2
                                       : geometry.size.width / 4))
                                .cornerRadius(8)
                                .background(RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(UIColor.systemBackground))
                                                .shadow(radius: 3, x: 0, y: 3))
                            Spacer()
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            if let releaseDate = movie.item.releaseDate {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .resizable()
                                        .frame(width: 12, height: 12)
                                    Text(releaseYear(from: releaseDate))
                                }
                            }
                            HStack {
                                Image(systemName: "clock.fill")
                                    .resizable()
                                    .frame(width: 12, height: 12)
                                Text(runtime(from: movie.details.runtimeMinutes))
                            }
                            RatingView(number: movie.item.rating)
                        }
                        .font(.subheadline)
                    }
                    VStack(alignment: .leading) {
                        Text(movie.item.title)
                            .font(.largeTitle).fontWeight(.bold)
                        Text(movie.item.overview)
                    }

                    Section(title: "Geners") {
                        ForEach(movie.details.genres) { genre in
                            Text(genre.name)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(6)
                                .background(Color.secondary)
                                .cornerRadius(6)
                        }
                    }
                                        
                    Section(title: "Recommendations") {
                        ForEach(recommended) { movie in
                            Button {
                                eventHandler(.select(movie))
                            } label: {
                                MovieCellView(movie: movie)
                                    .frame(width: 100 * (horizontalSizeClass == .compact ? 1 : 2),
                                           height: 250 * (horizontalSizeClass == .compact ? 1 : 2))
                                    .font(.caption)
                            }
                            .foregroundStyle(.primary)
                        }
                    }
                    
                    Section(title: "Producing Companies") {
                        ForEach(movie.details.companies) { company in
                            ImageView(imageSource: company.logo, placeholder: nil)
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                        }
                    }
                }
                .padding()
            }
        }
        .background(alignment: .top) {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    ZStack {
                        if let backdrop = movie.item.backdrop {
                            ImageView(imageSource: backdrop, placeholder: nil)
                                .aspectRatio(contentMode: .fill)
                                .frame(maxHeight: geometry.size.height / 2)
                                .frame(maxWidth: geometry.size.width)
                                .edgesIgnoringSafeArea(.all)
                                .transition(.opacity.animation(.smooth))
                            LinearGradient(gradient: Gradient(colors: [Color(UIColor.secondarySystemBackground), .clear]), startPoint: .bottom, endPoint: .top)
                        }
                    }
                    Color(UIColor.secondarySystemBackground)
                    Spacer()
                }
            }
            .ignoresSafeArea(.all)
        }
        .navigationTitle(movie.item.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func releaseYear(from date: Date) -> String {
        String(Calendar.current.component(.year, from: date))
    }
    
    private func runtime(from duration: Duration) -> String {
        duration.formatted(.time(pattern: .hourMinute))
    }
}

private struct Section<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    var body: some View {
        Text(title)
            .font(.headline).fontWeight(.semibold)
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                content()
            }
        }
        .scrollClipDisabled(true)
    }
}

#Preview {
    NavigationStack {
        MovieDetailView(movie: .mock(id: 100),
                        recommended: Movie.Item.mock(count: 10)) { _ in }
    }
}
