//
//  PosterImage.swift
//  TMDB
//
//  Created by Zsolt Molnár on 2024. 11. 24..
//

import Foundation
import SwiftUI

struct PosterFormat: ViewModifier {
    func body(content: Content) -> some View {
        content
            .aspectRatio(2/3, contentMode: .fit)
    }
}

extension View {
    func posterFormat() -> some View {
        modifier(PosterFormat())
    }
}
