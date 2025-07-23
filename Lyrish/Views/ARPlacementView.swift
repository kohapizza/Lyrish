//
//  ARPlacementView.swift
//  Lyrish
//
//  Created by 佐伯小遥 on 2025/07/23.
//

import Foundation
import SwiftUI

struct ARPlacementView: View {
    @StateObject private var viewModel = ARPlacementViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("Place")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button("Next") {
                            if currentStep < 2 {
                                currentStep += 1
                            } else {
                                viewModel.placeLyric()
                                dismiss()
                            }
                        }
                        .foregroundColor(.pink)
                        .disabled(!canProceed)
                    }
                    .padding()
                    
                    // Content
                    VStack {
                        if currentStep == 0 {
                            LyricInputStep(viewModel: viewModel)
                        } else if currentStep == 1 {
                            SongInfoStep(viewModel: viewModel)
                        } else {
                            MemoryStep(viewModel: viewModel)
                        }
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private var canProceed: Bool {
        switch currentStep {
        case 0:
            return !viewModel.lyricText.isEmpty
        case 1:
            return !viewModel.songTitle.isEmpty && !viewModel.artistName.isEmpty
        case 2:
            return !viewModel.memory.isEmpty
        default:
            return false
        }
    }
}

struct LyricInputStep: View {
    @ObservedObject var viewModel: ARPlacementViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Enter Lyrics")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            TextEditor(text: $viewModel.lyricText)
                .font(.body)
                .foregroundColor(.white)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
                .frame(height: 150)
                .padding()
        }
    }
}

struct SongInfoStep: View {
    @ObservedObject var viewModel: ARPlacementViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Song Information")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(spacing: 16) {
                TextField("Song Title", text: $viewModel.songTitle)
                    .textFieldStyle(CustomTextFieldStyle())
                
                TextField("Artist Name", text: $viewModel.artistName)
                    .textFieldStyle(CustomTextFieldStyle())
            }
            .padding()
        }
    }
}

struct MemoryStep: View {
    @ObservedObject var viewModel: ARPlacementViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add Memory")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            TextEditor(text: $viewModel.memory)
                .font(.body)
                .foregroundColor(.white)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
                .frame(height: 150)
                .padding()
        }
    }
}
