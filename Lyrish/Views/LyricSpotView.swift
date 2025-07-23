//
//  LyricSpotView.swift.swift
//  Lyrish
//
//  Created by 佐伯小遥 on 2025/07/23.
//

import SwiftUI

struct LyricSpotView: View {
    @StateObject private var viewModel = LyricSpotViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.08, green: 0.08, blue: 0.08).ignoresSafeArea()
                
                VStack {
                    Text("LyricSpot")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                    
                    // Content

                }
                
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    LyricSpotView()
}
