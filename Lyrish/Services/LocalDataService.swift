//
//  LocalDataService.swift
//  Lyrish
//
//  Created by 佐伯小遥 on 2025/07/23.
//

import Foundation
import CoreLocation

@MainActor
class LocalDataService: ObservableObject {
    static let shared = LocalDataService()
    
    @Published var currentUser: User
    @Published var lyricSpots: [LyricSpot] = []
    
    private init() {
        // サンプルユーザー
        self.currentUser = User(username: "ethan.carter", joinedDate: Calendar.current.date(byAdding: .year, value: -3, to: Date()) ?? Date())
        self.currentUser.lyricsCount = 12
        self.currentUser.likesCount = 24
        self.currentUser.followersCount = 36
        
        loadSampleData()
    }
    
    private func loadSampleData() {
        let sampleSongs = [
            Song(title: "Shake It Off", artist: "Taylor Swift", imageName: ""),
            Song(title: "Hotline Bling", artist: "Drake", imageName: ""),
            Song(title: "Bad Guy", artist: "Billie Eilish", imageName: "")
        ]
        
        let sampleLyrics = [
            "Shake it off, shake it off",
            "You used to call me on my cell phone",
            "I'm the bad guy, duh"
        ]
        
        let sampleMemories = [
            "This song always makes me think of dancing in the rain",
            "Late night drives through the city",
            "Feeling confident and unstoppable"
        ]
        
        for i in 0..<3 {
            let lyricSpot = LyricSpot(
                lyricText: sampleLyrics[i],
                song: sampleSongs[i],
                user: currentUser,
                location: CLLocationCoordinate2D(latitude: 37.7749 + Double(i) * 0.01, longitude: -122.4194 + Double(i) * 0.01),
                memory: sampleMemories[i]
            )
            lyricSpots.append(lyricSpot)
        }
    }
    
    func addLyricSpot(_ lyricSpot: LyricSpot) {
        lyricSpots.append(lyricSpot)
        currentUser.lyricsCount += 1
    }
    
    func getUserLyricSpots() -> [LyricSpot] {
        return lyricSpots.filter { $0.user.id == currentUser.id }
    }
}
