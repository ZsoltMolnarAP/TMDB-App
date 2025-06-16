//
//  Image.swift
//  TMDB
//
//  Created by Zsolt Molnár on 2024. 11. 23..
//

import Foundation
import SwiftUI

enum ImageSource: Codable, Hashable, Equatable {
    case local(String)
    case remote(URL)
}

struct ImageView: View {
    let imageSource: ImageSource
    let placeholder: Image?
    var body: some View {
        Group {
            switch imageSource {
            case .local(let name):
                Image(name)
                    .resizable()
            case .remote(let url):
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                } placeholder: {
                    ZStack(alignment: .center) {
                        Color(.clear)
                        if let placeholder {
                            placeholder
                                .resizable()
                                .frame(width: 64, height: 64)
                                .foregroundStyle(Color.primary)
                                .opacity(0.5)
                        }
                    }
                }
            }
        }
    }
}
