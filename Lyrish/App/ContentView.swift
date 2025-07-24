//
//  ContentView.swift
//  Lyrish
//
//  Created by 佐伯小遥 on 2025/07/23.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showingARPlacementSheet = false

    @StateObject private var arPlacementViewModel = ARPlacementViewModel()
    @StateObject private var locationManager = LocationManager() // ここでLocationManagerをインスタンス化

    var body: some View {
        ZStack {
            Group {
                if selectedTab == 0 {
                    LyricSpotView()
                        .environmentObject(arPlacementViewModel)
                } else if selectedTab == 1 {
                    ProfileView()
                }
            }
            
            // カスタムタブバー
            VStack(alignment: .leading) {
                Spacer()
                HStack {
                    TabButton(
                        iconName: "map.fill",
                        isSelected: selectedTab == 0
                    ) {
                        selectedTab = 0
                    }
                    
                    Button(action: {
                        showingARPlacementSheet = true
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
                    .offset(y: -13)
                    
                    TabButton(
                        iconName: "person.fill",
                        isSelected: selectedTab == 1
                    ) {
                        selectedTab = 1
                    }
                }
                .background(Color.black)
            }
        }
        .accentColor(.white)
        .sheet(isPresented: $showingARPlacementSheet) {
            RegisterLyricsView()
                .environmentObject(arPlacementViewModel)
        }
        // MARK: - 歌詞登録後に特定の歌詞をAR表示するフルスクリーンカバー
        .fullScreenCover(isPresented: $arPlacementViewModel.showARView) {
            if let lyricSpotToDisplay = arPlacementViewModel.lyricsToDisplayInAR {
                // ここでuserLocationを渡す
                ARViewContainer(lyricSpots: [lyricSpotToDisplay], userLocation: locationManager.location) // ここを修正！
                    .edgesIgnoringSafeArea(.all)
                    .overlay(alignment: .topLeading) {
                        Button("AR終了") {
                            arPlacementViewModel.showARView = false
                            arPlacementViewModel.lyricsToDisplayInAR = nil
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                        .padding(.top, 40)
                        .padding(.leading, 20)
                    }
            } else {
                EmptyView()
            }
        }
        .onAppear {
            locationManager.requestPermission() // アプリ起動時に位置情報許可をリクエスト
            locationManager.startUpdatingLocation() // 位置情報の更新を開始
        }
        .onDisappear {
            locationManager.stopUpdatingLocation() // アプリ終了時に更新を停止
        }
    }
}

struct TabButton: View {
    let iconName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: iconName)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isSelected ? .white : .gray)
            }
            .padding(.vertical, 3)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ContentView()
}
