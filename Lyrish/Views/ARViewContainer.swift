//
//  ARViewContainer.swift
//  Lyrish
//
//  Created by 佐伯小遥 on 2025/07/25.
//

import SwiftUI
import RealityKit
import ARKit
import CoreLocation

// SwiftUIでARViewを使用するためのUIViewRepresentable
struct ARViewContainer: UIViewRepresentable {
    var lyricSpots: [LyricSpot]
    var userLocation: CLLocation?
    
    // ARViewContainer.swift の makeUIView 関数内
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic

        // MARK: - ARGeoTrackingConfiguration の実行を一時的にコメントアウト (デバッグ用)
        // if ARGeoTrackingConfiguration.isSupported {
        //     let geoConfig = ARGeoTrackingConfiguration()
        //     arView.session.run(geoConfig)
        //     print("ARGeoTrackingConfiguration enabled.")
        // } else {
            arView.session.run(config) // 常に通常のARWorldTrackingConfiguration を実行
            print("ARWorldTrackingConfiguration forced enabled for debug.")
        // }

        arView.session.delegate = context.coordinator

        context.coordinator.arView = arView
        context.coordinator.lyricSpots = lyricSpots
        context.coordinator.userLocation = userLocation

        return arView
    }

//    func makeUIView(context: Context) -> ARView {
//        let arView = ARView(frame: .zero)
//
//        let config = ARWorldTrackingConfiguration()
//        config.planeDetection = [.horizontal, .vertical]
//        config.environmentTexturing = .automatic
//
//        // 現在地が利用可能であれば、地理的トラッキングを有効にする
//        if ARGeoTrackingConfiguration.isSupported {
//            let geoConfig = ARGeoTrackingConfiguration()
//            arView.session.run(geoConfig)
//            print("ARGeoTrackingConfiguration enabled.")
//        } else {
//            arView.session.run(config)
//            print("ARWorldTrackingConfiguration enabled.")
//        }
//        
//        arView.session.delegate = context.coordinator
//
//        context.coordinator.arView = arView
//        context.coordinator.lyricSpots = lyricSpots
//        context.coordinator.userLocation = userLocation
//        
//        print("DEBUG: ARViewContainer initialized with \(lyricSpots.count) lyric spots.")
//        
//        return arView
//    }

    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.lyricSpots = lyricSpots
        context.coordinator.userLocation = userLocation
        
        print("DEBUG: ARViewContainer updated with \(lyricSpots.count) lyric spots.")
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, ARSessionDelegate {
        weak var arView: ARView?
        var lyricSpots: [LyricSpot] = []
        var userLocation: CLLocation?

        private var placedAnchors: Set<UUID> = []

        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            print("DEBUG: AR Tracking State: \(frame.camera.trackingState)")
            
            if let arView = arView, frame.camera.trackingState == .normal {
                if !(session.configuration is ARGeoTrackingConfiguration) {
                    placeLyricsInAR(arView: arView)
                }
            }
        }
        
        // MARK: - ARGeoTrackingStatus.StateReason の最終的な修正
        func session(_ session: ARSession, didChange geoTrackingStatus: ARGeoTrackingStatus) {
            print("DEBUG: GeoTrackingStatus: \(String(describing: geoTrackingStatus.state)), Accuracy: \(String(describing: geoTrackingStatus.accuracy))")
            print("GeoTrackingStatus: \(String(describing: geoTrackingStatus.state)), Accuracy: \(String(describing: geoTrackingStatus.accuracy))")
            
            switch geoTrackingStatus.state {
            case .localized:
                if let arView = arView {
                    placeLyricsInAR(arView: arView)
                }
            case .notAvailable:
                print("GeoTracking is not available.")
            case .initializing:
                print("GeoTracking is initializing.")
            @unknown default:
                print("Unknown or new geoTrackingStatus state detected: \(geoTrackingStatus.state)")
            }
            
            // 精度がLimitedである場合のログは、stateの状態とは独立して確認できる
            if geoTrackingStatus.accuracy == .low || geoTrackingStatus.accuracy == .medium {
                 print("GeoTracking accuracy is limited. Current accuracy: \(String(describing: geoTrackingStatus.accuracy))")
                 // MARK: - ここを修正: if let を外し、String(describing:) で直接アクセス
                 print("GeoTracking state reason: \(String(describing: geoTrackingStatus.stateReason))")
            }
        }
        
        func placeLyricsInAR(arView: ARView) {
            guard let userLoc = userLocation else {
                print("User location is not available to place AR content.")
                return
            }
            
            guard let currentARConfiguration = arView.session.configuration else {
                print("ARSession configuration is nil.")
                return
            }

            for spot in lyricSpots {
                if placedAnchors.contains(spot.id) { continue }

                let lyricLocation = CLLocation(latitude: spot.location.latitude, longitude: spot.location.longitude)
                let distance = userLoc.distance(from: lyricLocation)
                
                guard distance < 1000 else {
                    print("Lyric spot too far (\(String(format: "%.1f", distance))m) to place in AR: \(spot.song.title) - \(spot.lyricText)")
                    continue
                }
                
                if currentARConfiguration is ARGeoTrackingConfiguration {
                    let geoAnchor = ARGeoAnchor(coordinate: spot.location)
                    arView.session.add(anchor: geoAnchor)
                    
                    addLyricEntity(to: arView, anchor: geoAnchor, lyricText: spot.lyricText, songTitle: spot.song.title)
                    placedAnchors.insert(spot.id)

                } else if currentARConfiguration is ARWorldTrackingConfiguration {
                    let x = Float(0)
                    let y = Float(0)
                    let z = Float(-1)

                    var transform = matrix_identity_float4x4
                    transform.columns.3.x = x
                    transform.columns.3.y = y
                    transform.columns.3.z = z
                    
                    let arAnchor = ARAnchor(transform: transform)
                    
                    arView.session.add(anchor: arAnchor)
                    
                    addLyricEntity(to: arView, anchor: arAnchor, lyricText: spot.lyricText, songTitle: spot.song.title)
                    placedAnchors.insert(spot.id)
                } else {
                    print("Unsupported AR configuration: \(String(describing: currentARConfiguration))")
                }
            }
        }
        
        private func addLyricEntity(to arView: ARView, anchor: ARAnchor, lyricText: String, songTitle: String) {
            let anchorEntity = AnchorEntity(anchor: anchor)

            let textMesh = MeshResource.generateText(
                lyricText,
                extrusionDepth: 0.01,
                font: .systemFont(ofSize: 3.5),
                containerFrame: CGRect(x: -0.5, y: -0.1, width: 1.0, height: 0.2),
                alignment: .center,
                lineBreakMode: .byWordWrapping
            )
            let textMaterial = SimpleMaterial(color: .white, isMetallic: false)
            let textEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])
            
            let songTitleMesh = MeshResource.generateText(
                songTitle,
                extrusionDepth: 0.005,
                font: .systemFont(ofSize: 0.05),
                containerFrame: CGRect(x: -0.5, y: -0.1, width: 1.0, height: 0.1),
                alignment: .center,
                lineBreakMode: .byWordWrapping
            )
            let songTitleMaterial = SimpleMaterial(color: .yellow, isMetallic: false)
            let songTitleEntity = ModelEntity(mesh: songTitleMesh, materials: [songTitleMaterial])
            songTitleEntity.position = SIMD3(0, -0.07, 0)

            let groupEntity = ModelEntity()
            groupEntity.addChild(textEntity)
            groupEntity.addChild(songTitleEntity)
            
            anchorEntity.addChild(groupEntity)
            arView.scene.addAnchor(anchorEntity)
        }
    }
}
