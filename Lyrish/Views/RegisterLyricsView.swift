//
//  RegisterLyricsView.swift
//  Lyrish
//
//  Created by 佐伯小遥 on 2025/07/23.
//

import Foundation
import SwiftUI

struct RegisterLyricsView: View {
    @StateObject private var viewModel = ARPlacementViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    let songs = [
        Song(title: "Please me (feat. MFS)", artist: "Pasocom Music Club", imageName: "album1"),
        Song(title: "Disco", artist: "mitsume", imageName: "album2"),
        Song(title: "Erica", artist: "Sad Kid Yaz", imageName: "album3"),
        Song(title: "sad song", artist: "the bercedes menz", imageName: "album4"),
        Song(title: "Monkeys", artist: "SATOH", imageName: "album5"),
        Song(title: "Loco Freestyle", artist: "Sad Kid Yaz", imageName: "album6"),
        Song(title: "Koi Wo Shita", artist: "Chara", imageName: "album7"),
        Song(title: "Money Rain (feat. v3geboy)", artist: "Sad Kid Yaz", imageName: "album8"),
        Song(title: "Weather Report", artist: "ミツメ", imageName: "album9")
    ]
    
    var filteredSongs: [Song] {
        if searchText.isEmpty {
            return songs
        } else {
            return songs.filter { song in
                song.title.localizedCaseInsensitiveContains(searchText) ||
                song.artist.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
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
                    
                    // Content

                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .padding(.leading, 12)
                        
                        TextField("Search audio", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.vertical, 12)
                            .padding(.trailing, 12)
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    
                    // Song List
                     List(filteredSongs, id: \.id) { song in
                         SongRowView(song: song)
                             .listRowSeparator(.hidden)
                             .listRowBackground(Color.clear)
                     }
                     .listStyle(PlainListStyle())
                     .padding(.top, 10)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct SongRowView: View {
    let song: Song
    
    var body: some View {
        HStack(spacing: 12) {
            // Album Art
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray4))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "music.note")
                        .foregroundColor(.gray)
                )
            
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
        .onTapGesture {
            // Handle song selection
            print("Selected: \(song.title)")
        }
    }
}


#Preview {
    RegisterLyricsView()
}
