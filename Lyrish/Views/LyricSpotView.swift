//
//  LyricSpotView.swift.swift
//  Lyrish
//
//  Created by 佐伯小遥 on 2025/07/23.
//

import SwiftUI
import MapKit // MapKitをインポート

struct LyricSpotView: View {
    @StateObject private var viewModel = LyricSpotViewModel()
    @StateObject private var locationManager = LocationManager() // ロケーションマネージャーを追加

    // マップの表示領域を管理するState
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917), // 東京の緯度経度を初期値に設定
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    var body: some View {
        NavigationView {
            ZStack {
                // マップビュー
                Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: viewModel.lyricSpots) { spot in
                    MapAnnotation(coordinate: spot.location) {
                        // マップ上のピンのデザイン
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
                    // ユーザーの位置情報が利用可能であれば、マップの中心をユーザーの現在地にする
                    if let userLocation = locationManager.location?.coordinate {
                        region.center = userLocation
                    } else {
                        // ロケーションパーミッションをリクエスト
                        locationManager.requestPermission()
                    }
                    viewModel.loadLyricSpots() // 歌詞スポットをロード
                    locationManager.startUpdatingLocation() // 位置情報の更新を開始
                }
                .onDisappear {
                    locationManager.stopUpdatingLocation() // 位置情報の更新を停止
                }

                VStack {
                    Spacer()
                    // 必要であればここにマップに関するUI要素を追加
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    LyricSpotView()
}
