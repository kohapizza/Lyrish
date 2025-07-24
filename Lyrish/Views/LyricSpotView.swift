//
//  LyricSpotView.swift.swift
//  Lyrish
//
//  Created by 佐伯小遥 on 2025/07/23.
//

import SwiftUI
import MapKit

struct LyricSpotView: View {
    @StateObject private var viewModel = LyricSpotViewModel()
    @StateObject private var locationManager = LocationManager()
    @EnvironmentObject var arPlacementViewModel: ARPlacementViewModel // EnvironmentObjectとして受け取る

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917), // 東京
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    @State private var showingAllLyricsAR = false // ARViewを直接開くためのState

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: viewModel.lyricSpots) { spot in
                    MapAnnotation(coordinate: spot.location) {
                        VStack {
                            Image(systemName: "music.note.house.fill")
                                .font(.title2)
                                .foregroundColor(.purple)
                            Text(spot.song.title)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .lineLimit(1)
                        }
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.black.opacity(0.7))
                                .shadow(radius: 3)
                        )
                    }
                }
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    if let userLocation = locationManager.location?.coordinate {
                        region.center = userLocation
                    } else {
                        locationManager.requestPermission()
                    }
                    viewModel.loadLyricSpots()
                    locationManager.startUpdatingLocation()
                }
                .onDisappear {
                    locationManager.stopUpdatingLocation()
                }

                // MARK: - ARモード開始ボタン
                Button(action: {
                    showingAllLyricsAR = true // 全ての歌詞ARビューを表示
                }) {
                    Image(systemName: "arkit")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.green, .cyan],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .shadow(radius: 5)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 80)

            }
            .navigationBarHidden(true)
            // MARK: - ARViewのフルスクリーン表示 (全歌詞スポット用)
            .fullScreenCover(isPresented: $showingAllLyricsAR) {
                // ここでuserLocationを渡す
                ARViewContainer(lyricSpots: viewModel.lyricSpots, userLocation: locationManager.location) // ここを修正！
                    .edgesIgnoringSafeArea(.all)
                    .overlay(alignment: .topLeading) {
                        Button("AR終了") {
                            showingAllLyricsAR = false
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                        .padding(.top, 40)
                        .padding(.leading, 20)
                    }
            }
        }
    }
}

#Preview {
    LyricSpotView()
        .environmentObject(ARPlacementViewModel()) // プレビュー用にViewModelを渡す
}
