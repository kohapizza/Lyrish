//
//  LyricSpotView.swift.swift
//  Lyrish
//
//  Created by 佐伯小遥 on 2025/07/23.
//

import SwiftUI

struct LyricSpotView: View {
    @StateObject private var viewModel = LyricSpotViewModel()
    @State private var showingARPlacement = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    // Header
                    HStack {
                        Text("LyricSpot")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image(systemName: "gearshape.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    
                    // Content
                    if viewModel.lyricSpots.isEmpty {
                        Spacer()
                        
                        VStack(spacing: 20) {
                            Image(systemName: "music.note")
                                .font(.system(size: 60))
                                .foregroundColor(.pink)
                            
                            Text("Groove On, Anywhere")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Uncover and exchange music lyrics linked to actual places using augmented reality.")
                                .font(.body)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.lyricSpots) { lyricSpot in
                                    LyricCard(lyricSpot: lyricSpot)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingARPlacement = true
                        }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [.pink, .purple],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                        }
                        .padding(.trailing)
                        .padding(.bottom, 80)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingARPlacement) {
                ARPlacementView()
            }
        }
    }
}

struct TabButton: View {
    let icon: String
    let isSelected: Bool
    
    var body: some View {
        Image(systemName: icon)
            .font(.title2)
            .foregroundColor(isSelected ? .pink : .gray)
            .frame(maxWidth: .infinity)
    }
}
