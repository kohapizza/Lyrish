//
//  LyricSpotViewModel.swift
//  Lyrish
//
//  Created by 佐伯小遥 on 2025/07/23.
//

import Foundation

@MainActor
class LyricSpotViewModel: ObservableObject {
    @Published var lyricSpots: [LyricSpot] = []
    
    private let dataService = LocalDataService.shared
    
    init() {
        loadLyricSpots()
    }
    
    func loadLyricSpots() {
        lyricSpots = dataService.lyricSpots
    }
    
    func addLyricSpot(_ lyricSpot: LyricSpot) {
        dataService.addLyricSpot(lyricSpot)
        loadLyricSpots()
    }
}
