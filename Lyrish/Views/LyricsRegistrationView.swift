//
//  LyricsRegistrationView.swift
//  Lyrish
//
//  Created by 佐伯小遥 on 2025/07/24.
//

import SwiftUI
import CoreLocation
import MapKit

struct LyricsRegistrationView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var arPlacementViewModel: ARPlacementViewModel
    @StateObject private var lyricsFetcher = LyricsFetcher()

    @State private var lines: [LyricLine] = []
    @State private var selectedLineId: UUID? = nil
    @State private var selectedLineText: String = ""

    @State private var selectedLocationForRegistration: CLLocationCoordinate2D? = nil
    @State private var selectedLocationNameForRegistration: String = "未選択"

    @State private var showingLocationSelectionSheet = false

    @State private var initialSongTitle: String
    @State private var initialArtistName: String
    @State private var initialImageName: String

    init(arPlacementViewModel: ARPlacementViewModel, songTitle: String, artistName: String, imageName: String) {
        _arPlacementViewModel = ObservedObject(wrappedValue: arPlacementViewModel)
        _initialSongTitle = State(initialValue: songTitle)
        _initialArtistName = State(initialValue: artistName)
        _initialImageName = State(initialValue: imageName)
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.08, green: 0.08, blue: 0.08).ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("歌詞を登録")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    LyricCard(lyricSpot: LyricSpot(lyricText: "", song: Song(title: arPlacementViewModel.songTitle, artist: arPlacementViewModel.artistName, imageName: arPlacementViewModel.imageName), user: LocalDataService.shared.currentUser, location: .init(), memory: ""))
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("歌詞を選択してください:")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        ScrollView {
                            if lyricsFetcher.isLoading {
                                ProgressView("歌詞取得中...")
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .foregroundColor(.white)
                                    .padding()
                            } else if let errorMessage = lyricsFetcher.errorMessage {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .padding()
                            } else if lines.isEmpty {
                                Text("歌詞が見つかりませんでした。")
                                    .foregroundColor(.gray)
                                    .padding()
                            } else {
                                ForEach(lines) { lyricLine in
                                    Text(lyricLine.text)
                                        .font(.body)
                                        .foregroundColor(.white)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 15)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(selectedLineId == lyricLine.id ? Color.purple.opacity(0.6) : Color.clear)
                                        .cornerRadius(8)
                                        .onTapGesture {
                                            selectedLineId = lyricLine.id
                                            selectedLineText = lyricLine.text
                                        }
                                }
                            }
                        }
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    if !selectedLineText.isEmpty {
                        Text("選択された歌詞:")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        TextEditor(text: .constant(selectedLineText))
                            .frame(height: 80)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .disabled(true)
                            .padding(.horizontal)
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("場所を設定:")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        Button(action: {
                            showingLocationSelectionSheet = true
                        }) {
                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundColor(.gray)
                                Text(selectedLocationNameForRegistration.isEmpty || selectedLocationNameForRegistration == "未選択" ? "タップして場所を選択" : selectedLocationNameForRegistration)
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("キャプションを追加:")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        TextField("この歌詞にまつわる思い出を入力", text: $arPlacementViewModel.memory, axis: .vertical)
                            .textFieldStyle(CustomTextFieldStyle())
                            .lineLimit(3...5)
                            .padding(.horizontal)
                    }
                    
                    CustomButton(title: "歌詞を登録", action: {
                        arPlacementViewModel.lyricText = selectedLineText
                        if let loc = selectedLocationForRegistration {
                            arPlacementViewModel.location = loc
                        }
                        arPlacementViewModel.placeLyric()
                        dismiss()
                    }, style: .primary)
                    .padding(.horizontal)
                    .disabled(lyricsFetcher.isLoading || selectedLineText.isEmpty || arPlacementViewModel.memory.isEmpty || selectedLocationForRegistration == nil)
                    
                    Spacer()
                }
            }
            .navigationBarItems(leading: Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
            })
            .sheet(isPresented: $showingLocationSelectionSheet) {
                LocationSelectionView(selectedLocation: $selectedLocationForRegistration, selectedLocationName: $selectedLocationNameForRegistration)
            }
            .onAppear {
                // MARK: - ここを修正: DispatchQueue.main.async を使ってプロパティ変更を遅延させる
                DispatchQueue.main.async {
                    arPlacementViewModel.songTitle = initialSongTitle
                    arPlacementViewModel.artistName = initialArtistName
                    arPlacementViewModel.imageName = initialImageName
                }

                // 歌詞の取得はTaskで非同期に行う
                Task {
                    // onAppear時にarPlacementViewModelのプロパティがまだ設定されていない可能性があるので、
                    // initialSongTitleとinitialArtistNameを直接使う
                    let fullQuery = "\(initialSongTitle) \(initialArtistName)"
                    await lyricsFetcher.fetchLyrics(for: fullQuery)
                    if lyricsFetcher.errorMessage == nil {
                        self.lines = lyricsFetcher.lyrics.split(separator: "\n")
                            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
                            .filter { !$0.isEmpty }
                            .map { LyricLine(text: $0) }
                    }
                }
            }
        }
    }
}

// プレビュープロバイダ (イニシャライザに合わせて修正)
struct LyricsRegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        LyricsRegistrationView(arPlacementViewModel: {
            let vm = ARPlacementViewModel()
            // プレビュー表示のために初期値を設定
            vm.songTitle = "Fancy Cozy (Preview)"
            vm.artistName = "who28 (Preview)"
            vm.imageName = ""
            return vm
        }(), songTitle: "Fancy Cozy (Preview)", artistName: "who28 (Preview)", imageName: "")
    }
}
