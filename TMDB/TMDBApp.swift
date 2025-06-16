//
//  TMDBApp.swift
//  TMDB
//
//  Created by Zsolt Molnár on 2024. 11. 20..
//

import SwiftUI

@main
struct TMDBApp: App {
    var body: some Scene {
        WindowGroup {
            MoviesCoordinator()
        }
        .modelContainer(for: MovieList.State.self)
    }
}
