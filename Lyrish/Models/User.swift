//
//  User.swift
//  Lyrish
//
//  Created by 佐伯小遥 on 2025/07/23.
//

import Foundation

struct User: Identifiable, Codable {
    let id = UUID()
    var username: String
    var joinedDate: Date
    var profileImageName: String?
    var lyricsCount: Int
    var likesCount: Int
    var followersCount: Int
    
    init(username: String, joinedDate: Date = Date()) {
        self.username = username
        self.joinedDate = joinedDate
        self.profileImageName = nil
        self.lyricsCount = 0
        self.likesCount = 0
        self.followersCount = 0
    }
}
