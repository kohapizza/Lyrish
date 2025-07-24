//
//  RegisterLyricsView.swift
//  Lyrish
//
//  Created by 佐伯小遥 on 2025/07/23.
//

import Foundation
import SwiftUI

struct RegisterLyricsView: View {
    // @StateObject private var viewModel = ARPlacementViewModel() // ここは削除し、EnvironmentObjectで受け取る
    @EnvironmentObject var arPlacementViewModel: ARPlacementViewModel // EnvironmentObjectとしてARPlacementViewModelを受け取る
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var suggestedSongs: [Song] = []

    @StateObject private var spotifyService = SpotifyAPIService() // SpotifyAPIServiceのインスタンス
    
    // 歌詞登録画面への遷移を制御するState
    @State private var showLyricsRegistration = false
    @State private var selectedSong: Song? // 選択された曲を保持

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.08, green: 0.08, blue: 0.08).ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 40, height: 5)
                        .padding()

                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .padding(.leading, 12)

                        TextField("Search audio", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.vertical, 12)
                            .padding(.trailing, 12)
                            .onChange(of: searchText) { newValue in
                                Task {
                                    await searchSpotifyTracks(query: newValue)
                                }
                            }
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                    .padding(.top, 10)

                     // Song List (Spotify APIからのサジェスト結果を表示)
                     List(suggestedSongs, id: \.id) { song in
                         SongRowView(song: song)
                             .listRowSeparator(.hidden)
                             .listRowBackground(Color.clear)
                             .onTapGesture {
                                 // 曲が選択されたらLyricsRegistrationViewに遷移
                                 selectedSong = song
                                 showLyricsRegistration = true
                             }
                     }
                     .listStyle(PlainListStyle())
                     .padding(.top, 10)

                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showLyricsRegistration) {
                // 歌詞登録画面に遷移し、選択された曲情報を渡す
                if let song = selectedSong {
                    // LyricsRegistrationViewに既存のARPlacementViewModelインスタンスを渡す
                    LyricsRegistrationView(arPlacementViewModel: arPlacementViewModel, // EnvironmentObjectを使用せず、直接ViewModelを渡す
                                           songTitle: song.title,
                                           artistName: song.artist,
                                           imageName: song.imageName)
                }
            }
        }
    }

    // Spotify APIを呼び出す非同期関数
    func searchSpotifyTracks(query: String) async {
        guard !query.isEmpty else {
            suggestedSongs = []
            return
        }
        do {
            let tracks = try await spotifyService.searchTracks(query: query)
            suggestedSongs = tracks
        } catch {
            print("Error searching Spotify: \(error)")
            suggestedSongs = []
        }
    }
}

// SongRowViewは変更なし
struct SongRowView: View {
    let song: Song

    var body: some View {
        HStack(spacing: 12) {
            // Album Art
            if let url = URL(string: song.imageName) {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray4))
                        .overlay(
                            Image(systemName: "music.note")
                                .foregroundColor(.gray)
                        )
                }
                .frame(width: 50, height: 50)
                .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray4))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "music.note")
                            .foregroundColor(.gray)
                    )
            }

            // Song Info
            VStack(alignment: .leading, spacing: 2) {
                Text(song.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)

                Text(song.artist)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }.lineLimit(1)

            Spacer()
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}


#Preview {
    // プレビュー用にEnvironmentObjectを渡す必要がある
    RegisterLyricsView()
        .environmentObject(ARPlacementViewModel()) // ARPlacementViewModelのインスタンスを渡す
}
