//
//  Song.swift
//  Lyrish
//
//  Created by 佐伯小遥 on 2025/07/23.
//

import Foundation

struct Song: Identifiable, Codable {
    let id = UUID()
    let title: String
    let artist: String
    let imageName: String
    
    init(title: String, artist: String, imageName: String) {
        self.title = title
        self.artist = artist
        self.imageName = imageName
    }
}

// 歌詞の各行を表す構造体（一意のIDを持つ）
struct LyricLine: Identifiable, Equatable {
    let id = UUID() // 各行に一意のIDを付与
    let text: String // 歌詞のテキスト内容

    // Equatableに準拠させることで、選択時の比較がより安全になる
    static func == (lhs: LyricLine, rhs: LyricLine) -> Bool {
        lhs.id == rhs.id
    }
}
