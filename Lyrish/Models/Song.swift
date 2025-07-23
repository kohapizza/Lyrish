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
