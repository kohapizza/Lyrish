//
//  ARPlacementViewModel.swift
//  Lyrish
//
//  Created by 佐伯小遥 on 2025/07/23.
//

import Foundation
import CoreLocation

@MainActor
class ARPlacementViewModel: ObservableObject {
    @Published var lyricText: String = ""
    @Published var songTitle: String = ""
    @Published var artistName: String = ""
    @Published var memory: String = ""
    @Published var isPlacing: Bool = false
    
    private let dataService = LocalDataService.shared
    private let locationManager = LocationManager()
    
    func placeLyric() {
        guard !lyricText.isEmpty, !songTitle.isEmpty, !artistName.isEmpty else { return }
        
        let song = Song(title: songTitle, artist: artistName)
        let location = locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        
        let lyricSpot = LyricSpot(
            lyricText: lyricText,
            song: song,
            user: dataService.currentUser,
            location: location,
            memory: memory
        )
        
        dataService.addLyricSpot(lyricSpot)
        clearForm()
    }
    
    private func clearForm() {
        lyricText = ""
        songTitle = ""
        artistName = ""
        memory = ""
    }
}
