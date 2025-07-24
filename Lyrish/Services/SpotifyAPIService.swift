//
//  SpotifyAPIService.swift
//  Lyrish
//
//  Created by 佐伯小遥 on 2025/07/24.
//

import Foundation

class SpotifyAPIService: ObservableObject {
    private let clientID = "b6c31d7809fc44f5bf94806ce6a4f654"
    private let clientSecret = "72d79a96af8640789ad0904c6e2eab91"
    private var accessToken: String?

    // アクセストークンを取得するメソッド
    func getAccessToken() async throws {
        guard let url = URL(string: "https://accounts.spotify.com/api/token") else {
            throw URLError(.badURL)
        }

        let credentials = "\(clientID):\(clientSecret)"
        let base64Credentials = Data(credentials.utf8).base64EncodedString()

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "grant_type=client_credentials".data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
        self.accessToken = tokenResponse.access_token
    }

    // 曲を検索するメソッド
    func searchTracks(query: String) async throws -> [Song] {
        if accessToken == nil {
            try await getAccessToken() // アクセストークンがなければ取得
        }

        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.spotify.com/v1/search?q=\(encodedQuery)&type=track&limit=10") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken ?? "")", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let searchResponse = try JSONDecoder().decode(SpotifySearchResponse.self, from: data)
        return searchResponse.tracks.items.map { item in
            Song(title: item.name, artist: item.artists.first?.name ?? "Unknown Artist", imageName: item.album.images.first?.url ?? "")
        }
    }
}

// Spotify APIのレスポンスをデコードするための構造体
struct TokenResponse: Decodable {
    let access_token: String
    let token_type: String
    let expires_in: Int
}

struct SpotifySearchResponse: Decodable {
    let tracks: Tracks
}

struct Tracks: Decodable {
    let items: [TrackItem]
}

struct TrackItem: Decodable {
    let name: String
    let artists: [Artist]
    let album: Album
}

struct Artist: Decodable {
    let name: String
}

struct Album: Decodable {
    let images: [ImageObject]
}

struct ImageObject: Decodable {
    let url: String
    let height: Int
    let width: Int
}
