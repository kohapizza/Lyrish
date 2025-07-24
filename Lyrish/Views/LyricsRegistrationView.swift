//
//  LyricsRegistrationView.swift
//  Lyrish
//
//  Created by 佐伯小遥 on 2025/07/24.
//

import SwiftUI
import CoreLocation
import MapKit // MapKitをインポート (Reverse Geocodingのため)

struct LyricsRegistrationView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var arPlacementViewModel: ARPlacementViewModel
    @StateObject private var lyricsFetcher = LyricsFetcher()
    // LocationManagerはLocationSelectionViewに移動
    // @StateObject private var locationManager = LocationManager()

    @State private var lines: [LyricLine] = []
    @State private var selectedLineId: UUID? = nil
    @State private var selectedLineText: String = ""

    // 場所関連のState変数 (LocationSelectionViewと共有)
    @State private var selectedLocationForRegistration: CLLocationCoordinate2D? = nil
    @State private var selectedLocationNameForRegistration: String = "未選択"

    @State private var showingLocationSelectionSheet = false // マップシート表示制御

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
                    
                    // 歌詞選択エリア
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
                    
                    // 選択された歌詞のプレビュー（確認用）
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
                    
                    // MARK: - 場所の選択エリア
                    VStack(alignment: .leading, spacing: 5) {
                        Text("場所を設定:")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        Button(action: {
                            showingLocationSelectionSheet = true // マップシートを表示
                        }) {
                            HStack {
                                Image(systemName: "mappin.and.ellipse") // ピンアイコンに変更
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
                    
                    // キャプションの入力
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
                    
                    // 登録ボタン
                    CustomButton(title: "歌詞を登録", action: {
                        arPlacementViewModel.lyricText = selectedLineText
                        if let loc = selectedLocationForRegistration {
                            arPlacementViewModel.location = loc // マップで選択された場所を設定
                        }
                        arPlacementViewModel.placeLyric()
                        dismiss()
                    }, style: .primary)
                    .padding(.horizontal)
                    // 場所が選択されていない場合はボタンを無効化
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
            // .navigationBarHidden(true) // カスタムナビゲーションバーを使用しない場合はコメントアウト
            .sheet(isPresented: $showingLocationSelectionSheet) {
                // LocationSelectionViewを表示し、選択された場所と地名をバインディングで受け取る
                LocationSelectionView(selectedLocation: $selectedLocationForRegistration, selectedLocationName: $selectedLocationNameForRegistration)
            }
            .onAppear {
                // 歌詞の取得は変更なし
                Task {
                    let fullQuery = "\(arPlacementViewModel.songTitle) \(arPlacementViewModel.artistName)"
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

// プレビュープロバイダ
struct LyricsRegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        LyricsRegistrationView(arPlacementViewModel: {
            let vm = ARPlacementViewModel()
            vm.songTitle = "Fancy Cozy"
            vm.artistName = "who28"
            vm.imageName = ""
            return vm
        }())
    }
}
