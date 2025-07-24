//
//  LyricsFetcher.swift
//  Lyrish
//
//  Created by 佐伯小遥 on 2025/07/24.
//

import Foundation
import SwiftSoup
import Combine

enum LyricsFetcherError: Error, LocalizedError {
    case songNotFound
    case failedToFetchLyricsURL
    case failedToParseHTML
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .songNotFound:
            return "指定された曲の歌詞が見つかりませんでした。"
        case .failedToFetchLyricsURL:
            return "歌詞のURLの取得に失敗しました。"
        case .failedToParseHTML:
            return "歌詞ページの解析に失敗しました。"
        case .networkError(let error):
            return "ネットワークエラー: \(error.localizedDescription)"
        }
    }
}

@MainActor
class LyricsFetcher: ObservableObject {
    @Published var lyrics: String = "歌詞を読み込み中..."
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let accessToken = "8St_ldH1Li-4nTPb99lWmDOIAP4KbaHnPmUtFFBlUCawrwbIIt1VxlE2JSSRM7hT" // あなたのアクセストークンに置き換えてください

    func fetchLyrics(for query: String) async {
        isLoading = true
        errorMessage = nil
        lyrics = "歌詞を読み込み中..."

        do {
            guard let lyricsURL = try await searchSong(query: query) else {
                throw LyricsFetcherError.songNotFound
            }
            try await getLyrics(from: lyricsURL)
        } catch let error as LyricsFetcherError {
            errorMessage = error.localizedDescription
            lyrics = errorMessage ?? "エラーが発生しました。"
            print("LyricsFetcherError: \(error)")
        } catch {
            errorMessage = "予期せぬエラーが発生しました: \(error.localizedDescription)"
            lyrics = errorMessage ?? "エラーが発生しました。"
            print("Unexpected error: \(error)")
        }
        isLoading = false
    }

    private func searchSong(query: String) async throws -> String? {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        guard let url = URL(string: "https://api.genius.com/search?q=\(encodedQuery)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let hits = (json["response"] as? [String: Any])?["hits"] as? [[String: Any]],
               let result = hits.first?["result"] as? [String: Any],
               let url = result["url"] as? String {
                return url
            } else {
                return nil
            }
        } catch {
            throw LyricsFetcherError.networkError(error)
        }
    }
    
        private func getLyrics(from urlString: String) async throws {
            guard let url = URL(string: urlString) else {
                throw URLError(.badURL)
            }

            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }

            guard let html = String(data: data, encoding: .utf8) else {
                throw LyricsFetcherError.failedToParseHTML
            }

            do {
                let doc = try SwiftSoup.parse(html)
                
                // 歌詞の主要なコンテナをすべて選択
                // data-lyrics-container="true" 属性を持つdiv要素が最も確実
                // または、クラスがLyrics__Containerで始まり、かつLyricsHeader__Containerでないもの
                let allLyricsContainers = try doc.select("div[data-lyrics-container='true'], div[class^=Lyrics__Container]:not([class^=LyricsHeader__Container])").array()

                // 歌詞コンテナが一つも見つからない場合はエラー
                guard !allLyricsContainers.isEmpty else {
                    throw LyricsFetcherError.songNotFound
                }
                
                var fullLyrics = ""

                // 各歌詞コンテナをループして処理
                for container in allLyricsContainers {
                    // コンテナのコピーを作成し、そのコピーから不要な部分を削除する
                    // `outerHtml`から再パースすることで、各コンテナが独立したDOMとして扱われる
                    let editableContainer = try SwiftSoup.parse(container.outerHtml()).body()?.children().first()

                    guard let finalEditableContainer = editableContainer else { continue } // コピーに失敗したらスキップ

                    // --- 不要な要素の削除（ここも各コンテナに対して適用） ---
                    try finalEditableContainer.select("div[class^=LyricsHeader__Container]").remove()
                    try finalEditableContainer.select("h2[class^=LyricsHeader__Title]").remove()
                    try finalEditableContainer.select("button[class^=ContributorsCreditSong__Container]").remove()
                    
                    // ページ下部に表示される「あなたも好きかもしれない」などのセクションも削除
                    try finalEditableContainer.select("div[class^=Lyrics__MoreSectionHeader]").remove()
                    try finalEditableContainer.select("div[class^=MoreSongs__Container]").remove()
                    // --------------------------------------------------------

                    // <br>タグを実際の改行に置き換える（各コンテナ内で処理） -> 改行\nだとうまくいかない
                    for br in try finalEditableContainer.select("br").array() {
                        try br.after("XXX")
                        try br.remove()
                    }
                    
                    // DOMがクリーンになった後で、コンテナからテキストを抽出
                    let rawLyricsText = try finalEditableContainer.text()
                    
                    print("rawLyricsText: ", rawLyricsText)

                    // 行ごとに分割し、空行やフィルタリング対象の行を除外
                    var lines : [String] = rawLyricsText.split(separator: "XXX").map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
                    
                    print("lines: ", lines)
                    
                    var cleanedLines: [String] = []
                    for line in lines {
                        if line.isEmpty { continue }
                        
                        let lowercasedLine = line.lowercased()
                        
                        // 厳密なフィルタリング条件 (特定のキーワードを含む行を除外)
                        if lowercasedLine.contains("contributors") ||
                           (lowercasedLine.contains("lyrics") && line.count < 30) ||
                           lowercasedLine.contains("you might also like") ||
                           lowercasedLine.contains("read about") ||
                           lowercasedLine.contains("embed") ||
                           lowercasedLine.contains("all rights reserved") ||
                           lowercasedLine.hasPrefix("produced by") ||
                           lowercasedLine.hasPrefix("written by")
                        {
                            continue
                        }
                        cleanedLines.append(line + "\n")
                    }
                    
                    // 各コンテナから抽出した歌詞を結合
                    let extractedLyricsFromContainer = cleanedLines.joined(separator: "\n")
                    
                    print("extractedLyricsFromContainer: ", extractedLyricsFromContainer)
                    
                    if !extractedLyricsFromContainer.isEmpty {
                        // コンテナ間に改行を挿入して結合
                        fullLyrics += (fullLyrics.isEmpty ? "" : "\n\n") + extractedLyricsFromContainer
                    }
                }
                
                if fullLyrics.isEmpty {
                    //throw LyricsFetcherError.lyricsNotFoundInContainer
                }
                // fullLyricsに\nを含んだ歌詞が入っていて欲しい
                self.lyrics = fullLyrics
                
            } catch let error as LyricsFetcherError {
                throw error
            } catch {
                print("SwiftSoup parsing error or element not found: \(error)")
                throw LyricsFetcherError.failedToParseHTML
            }
        }
    
    

//    private func getLyrics(from urlString: String) async throws {
//        guard let url = URL(string: urlString) else {
//            throw URLError(.badURL)
//        }
//
//        let (data, response) = try await URLSession.shared.data(from: url)
//
//        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
//            throw URLError(.badServerResponse)
//        }
//
//        guard let html = String(data: data, encoding: .utf8) else {
//            throw LyricsFetcherError.failedToParseHTML
//        }
//
//        do {
//            let doc = try SwiftSoup.parse(html)
//             
//             // 歌詞の主要なコンテナを探す
//            let lyricsDivs = try doc.select("div[class^=Lyrics__Container]:not([class^=LyricsHeader__Container])").array()
//            
//            print("lyricsDivs", lyricsDivs) // lyricsDivs 要素一つ
//            
//            var fullLyrics = ""
//            
//            print("lyricsLength: ", lyricsDivs.count)
//
//            for element in lyricsDivs {
//                // `<br>`タグを明示的に改行として扱うために、outerHtmlからテキストを抽出し、
//                // `<br>`を改行文字に置換してからtext()を取得するアプローチを試みます。
//                let htmlContent = try element.outerHtml()
//                let cleanedHtmlContent = htmlContent.replacingOccurrences(of: "<br>", with: "\n\n")
//                                                    .replacingOccurrences(of: "<br/>", with: "\n\n")
//                                                    .replacingOccurrences(of: "<br />", with: "\n\n")
//                
//                // 置換後のHTMLからテキストを再解析
//                let cleanedDoc = try SwiftSoup.parse(cleanedHtmlContent)
//                let lyricsFragment = try cleanedDoc.text()
//                
//                print("lyricsFragment: ", lyricsFragment)
//                
//                // 空行や過剰な改行をトリム
//                let trimmedFragment = lyricsFragment.components(separatedBy: .newlines)
//                                                     .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
//                                                     .joined(separator: "\n")
//                
//                if !trimmedFragment.isEmpty {
//                    fullLyrics += (fullLyrics.isEmpty ? "" : "\n\n") + trimmedFragment
//                }
//            }
//            
//            if fullLyrics.isEmpty {
//                throw LyricsFetcherError.songNotFound
//            }
//            self.lyrics = fullLyrics
//            print("fullLyrics:", fullLyrics)
//            
//        } catch {
//            print("SwiftSoup parsing error or element not found: \(error)")
//            throw LyricsFetcherError.failedToParseHTML
//        }
//    }
}
