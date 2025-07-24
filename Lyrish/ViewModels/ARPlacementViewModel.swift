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
    @Published var imageName: String = ""
    @Published var memory: String = ""
    @Published var isPlacing: Bool = false
    
    @Published var location: CLLocationCoordinate2D? // 登録する場所の座標

    // MARK: - AR表示のために追加するプロパティ
    @Published var showARView: Bool = false // ARビューを表示するかどうかのフラグ
    @Published var lyricsToDisplayInAR: LyricSpot? // ARで表示する特定のLyricSpot

    private let dataService = LocalDataService.shared

    func placeLyric() {
        guard !lyricText.isEmpty, !songTitle.isEmpty, !artistName.isEmpty else { return }
        guard let actualLocation = location else {
            print("Error: Location is not set for lyric spot.")
            return
        }
        
        let song = Song(title: songTitle, artist: artistName, imageName: imageName)
        
        let newLyricSpot = LyricSpot( // ローカル変数に変更
            lyricText: lyricText,
            song: song,
            user: dataService.currentUser,
            location: actualLocation,
            memory: memory
        )

        dataService.addLyricSpot(newLyricSpot)
        
        // 登録後、このスポットをARで表示する準備
        self.lyricsToDisplayInAR = newLyricSpot
        self.showARView = true // ARビューを表示するフラグを立てる
        
        clearForm() // フォームはクリアする
    }
    
    private func clearForm() {
        lyricText = ""
        songTitle = ""
        artistName = ""
        memory = ""
        location = nil
        // showARView と lyricsToDisplayInAR はクリアしない（AR表示のために保持）
    }
}
