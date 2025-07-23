//
//  LyricCard.swift
//  Lyrish
//
//  Created by 佐伯小遥 on 2025/07/23.
//

import SwiftUI

struct LyricCard: View {
    let lyricSpot: LyricSpot
    
    var body: some View {
        HStack(spacing: 12) {
            // Album Art Placeholder
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.pink, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "music.note")
                        .font(.title3)
                        .foregroundColor(.white)
                )
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(lyricSpot.song.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(lyricSpot.song.artist)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.2))
        )
    }
}
