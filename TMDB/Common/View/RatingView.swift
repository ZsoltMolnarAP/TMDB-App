//
//  RatingView.swift
//  TMDB
//
//  Created by Zsolt Molnár on 2024. 11. 24..
//

import Foundation
import SwiftUI

struct RatingView: View {
    let number: Float
    var body: some View {
        HStack {
            Image(systemName: "star.leadinghalf.filled")
                .resizable()
                .frame(width: 12, height: 12)
                .foregroundColor(.yellow)
            Text(formattedRating(number))
        }
    }
    
    static let ratingFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return formatter
    }()
    
    func formattedRating(_ rating: Float) -> String {
        .init(RatingView.ratingFormatter.string(from: NSNumber(value: rating)) ?? "")
    }
}
