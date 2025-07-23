//
//  ProfileView.swift
//  Lyrish
//
//  Created by 佐伯小遥 on 2025/07/23.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Profile Header
                    VStack(spacing: 12) {
                        // Profile Image
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.pink, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 35))
                                    .foregroundColor(.white)
                            )
                        
                        // User Info
                        VStack(spacing: 4) {
                            Text("Ethan Carter")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("@ethan.carter")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Text(viewModel.joinedYearText)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Stats
                    HStack(spacing: 30) {
                        StatView(number: viewModel.user.lyricsCount, label: "Lyrics")
                        StatView(number: viewModel.user.likesCount, label: "Likes")
                        StatView(number: viewModel.user.followersCount, label: "Followers")
                    }
                    .padding(.vertical)
                    
                    // Tabs
                    HStack {
                        Text("Lyrics")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.bottom, 8)
                            .overlay(
                                Rectangle()
                                    .frame(height: 2)
                                    .foregroundColor(.pink),
                                alignment: .bottom
                            )
                        
                        Spacer()
                        
                        Text("Activity")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    // Lyrics List
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.userLyricSpots) { lyricSpot in
                                LyricCard(lyricSpot: lyricSpot)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
}

struct StatView: View {
    let number: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(number)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(minWidth: 60)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}
