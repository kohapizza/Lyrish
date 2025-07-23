//
//  ContentView.swift
//  Lyrish
//
//  Created by 佐伯小遥 on 2025/07/23.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            LyricSpotView()
                .tabItem {
                    Image(systemName: "house.fill")
                }
                .tag(0)
            
            Text("Map View")
                .tabItem {
                    Image(systemName: "location.fill")
                }
                .tag(1)
            
            Text("Search View")
                .tabItem {
                    Image(systemName: "magnifyingglass")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                }
                .tag(3)
        }
        .accentColor(.pink)
    }
}
