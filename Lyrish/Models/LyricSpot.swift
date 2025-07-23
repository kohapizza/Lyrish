//
//  LyricSpot.swift
//  Lyrish
//
//  Created by 佐伯小遥 on 2025/07/23.
//

import Foundation
import CoreLocation

struct LyricSpot: Identifiable, Codable {
    let id = UUID()
    let lyricText: String
    let song: Song
    let user: User
    let location: CLLocationCoordinate2D
    let memory: String
    let createdDate: Date
    var likesCount: Int
    
    init(lyricText: String, song: Song, user: User, location: CLLocationCoordinate2D, memory: String) {
        self.lyricText = lyricText
        self.song = song
        self.user = user
        self.location = location
        self.memory = memory
        self.createdDate = Date()
        self.likesCount = 0
    }
}

extension CLLocationCoordinate2D: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
    
    private enum CodingKeys: String, CodingKey {
        case latitude, longitude
    }
}
