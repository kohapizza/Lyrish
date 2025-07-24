//
//  LocationSelectionView.swift
//  Lyrish
//
//  Created by 佐伯小遥 on 2025/07/24.
//

import SwiftUI
import MapKit
import CoreLocation

struct LocationSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var locationManager = LocationManager()

    // 選択された場所の座標をバインディングで親ビューに渡す
    @Binding var selectedLocation: CLLocationCoordinate2D?
    // 選択された場所の地名をバインディングで親ビューに渡す
    @Binding var selectedLocationName: String

    // マップの表示領域
    @State private var region: MKCoordinateRegion

    // マップ上のピンの座標 (ユーザーがドラッグして選択)
    @State private var pinLocation: CLLocationCoordinate2D

    init(selectedLocation: Binding<CLLocationCoordinate2D?>, selectedLocationName: Binding<String>) {
        _selectedLocation = selectedLocation
        _selectedLocationName = selectedLocationName

        // 初期表示領域は、既に選択されている場所か、デフォルトの東京、またはユーザーの現在地
        _region = State(initialValue: MKCoordinateRegion(
            center: selectedLocation.wrappedValue ?? CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917), // 東京
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01) // ズームレベル
        ))
        // ピンの初期位置も同様
        _pinLocation = State(initialValue: selectedLocation.wrappedValue ?? CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917))
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: [IdentifiablePoint(coordinate: pinLocation)]) { item in
                    MapAnnotation(coordinate: item.coordinate) {
                        Image(systemName: "pin.fill")
                            .font(.title)
                            .foregroundColor(.purple)
                            .offset(y: -15) // ピンの先端を座標に合わせる
                            .gesture(
                                DragGesture()
                                    .onChanged { gesture in
                                        // マップの中心を移動中のピンに合わせる
                                        region.center = convertPointToCoordinate(point: gesture.location, in: .local)
                                    }
                                    .onEnded { gesture in
                                        // ドラッグ終了時にピンの位置を確定し、地名を更新
                                        pinLocation = convertPointToCoordinate(point: gesture.location, in: .local)
                                        updateLocationName(for: pinLocation)
                                    }
                            )
                    }
                }
                .edgesIgnoringSafeArea(.all)
                .onTapGesture { point in // マップタップでピンを移動
                    // タップ位置を座標に変換し、ピンと中心を更新
                    let coordinate = convertPointToCoordinate(point: point, in: .local) // この行はダミー。MapKitのonTapGestureは直接座標を返さない
                                                                                        // そのため、より詳細な実装が必要
                    // 簡易的な実装として、タップされた画面中央にピンを移動させる
                    pinLocation = region.center
                    updateLocationName(for: pinLocation)
                }
                
                // オーバーレイUI
                VStack {
                    HStack {
                        Button("キャンセル") {
                            dismiss()
                        }
                        .foregroundColor(.white)
                        .padding()
                        
                        Spacer()
                        
                        Text("場所を選択")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button("選択") {
                            selectedLocation = pinLocation
                            updateLocationName(for: pinLocation) // 念のため最終更新
                            dismiss()
                        }
                        .foregroundColor(.purple)
                        .padding()
                    }
                    .background(Color.black.opacity(0.8))
                    
                    Spacer()
                    
                    VStack {
                        Text(selectedLocationName.isEmpty ? "ピンを移動して場所を選択してください" : selectedLocationName)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Capsule().fill(Color.black.opacity(0.6)))
                    }
                    .padding(.bottom, 20)
                }
            }
            .onAppear {
                locationManager.requestPermission()
                locationManager.startUpdatingLocation()
                
                // 現在地が利用可能であれば、マップの中心とピンを現在地に設定
                if let userLocation = locationManager.location?.coordinate {
                    region.center = userLocation
                    pinLocation = userLocation
                    updateLocationName(for: userLocation)
                } else {
                    // 既に選択されている場所がある場合はその地名を取得
                    if let existingLoc = selectedLocation {
                        updateLocationName(for: existingLoc)
                    } else {
                        // デフォルト位置の地名を取得
                        updateLocationName(for: pinLocation)
                    }
                }
            }
            .onDisappear {
                locationManager.stopUpdatingLocation()
            }
            .onChange(of: locationManager.location) { newLocation in
                // 現在地が更新されたが、まだ場所が選択されていない場合のみ初期位置を更新
                if selectedLocation == nil, let loc = newLocation {
                    region.center = loc.coordinate
                    pinLocation = loc.coordinate
                    updateLocationName(for: loc.coordinate)
                }
            }
            // マップ領域が変更されたら、ピンの位置を中心に合わせ、地名を更新
            .onChange(of: region.center) { newCenter in
                pinLocation = newCenter
                updateLocationName(for: newCenter)
            }
        }
    }

    // Identifiableプロトコルに準拠したヘルパー構造体 (MapAnnotation用)
    struct IdentifiablePoint: Identifiable {
        let id = UUID()
        let coordinate: CLLocationCoordinate2D
    }

    // 地名を取得し、selectedLocationNameを更新
    private func updateLocationName(for coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Reverse geocoding error: \(error.localizedDescription)")
                self.selectedLocationName = "地名取得エラー"
                return
            }

            if let placemark = placemarks?.first {
                var nameComponents: [String] = []
                if let name = placemark.name { nameComponents.append(name) }
                else if let thoroughfare = placemark.thoroughfare { nameComponents.append(thoroughfare) }
                else if let locality = placemark.locality { nameComponents.append(locality) }
                else if let administrativeArea = placemark.administrativeArea { nameComponents.append(administrativeArea) }

                if !nameComponents.isEmpty {
                    self.selectedLocationName = nameComponents.joined(separator: ", ")
                } else {
                    self.selectedLocationName = "場所名不明"
                }
            } else {
                self.selectedLocationName = "場所名不明"
            }
        }
    }
    
    // ジェスチャーポイントから座標に変換するダミー関数 (MapKitのonTapGestureは座標を直接返さないため)
    // 実際の実装では、MKMapViewDelegateやUIGestureRecognizerで詳細な座標取得が必要
    private func convertPointToCoordinate(point: CGPoint, in space: CoordinateSpace) -> CLLocationCoordinate2D {
        // 現在のMapビューの可視領域の中心を返す（簡易的な例）
        // 実際のタップ位置の座標を正確に取得するには、より複雑なMapKitのAPIを使用する必要があります。
        // 例えば、MKMapViewDelegateを使ってUITapGestureRecognizerをMapViewに追加し、
        // tap.location(in: mapView) と mapView.convert(point, toCoordinateFrom: mapView) を使う。
        return region.center
    }
}


// プレビュー用
struct LocationSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        LocationSelectionView(selectedLocation: .constant(nil), selectedLocationName: .constant("場所を選択してください"))
    }
}
