//
//  ProfileViewModel.swift
//  Lyrish
//
//  Created by 佐伯小遥 on 2025/07/23.
//

import Foundation

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User
    @Published var userLyricSpots: [LyricSpot] = []
    
    private let dataService = LocalDataService.shared
    
    init() {
        self.user = dataService.currentUser
        loadUserLyricSpots()
    }
    
    func loadUserLyricSpots() {
        userLyricSpots = dataService.getUserLyricSpots()
    }
    
    var joinedYearText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return "Joined \(formatter.string(from: user.joinedDate))"
    }
}
