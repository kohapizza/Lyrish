//
//  ContentView.swift
//  Lyrish
//
//  Created by 佐伯小遥 on 2025/07/23.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    @State private var showingARPlacement = false
    
    var body: some View {
        ZStack {
            // TabViewの代わりに条件分岐を使用
            Group {
                if selectedTab == 0 {
                    LyricSpotView()
                } else if selectedTab == 1 {
                    ProfileView()
                }
            }
            
            // カスタムタブバー
            VStack(alignment: .leading) {
                Spacer()
                HStack {
                    // ホーム地図タブ
                    TabButton(
                        iconName: "house.fill",
                        isSelected: selectedTab == 0
                    ) {
                        selectedTab = 0
                    }
                    
                    // 中央の目立つボタン
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
                    .offset(y: -13)
                    
                    // プロフィール
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
        .sheet(isPresented: $showingARPlacement) {
            RegisterLyricsView()
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
