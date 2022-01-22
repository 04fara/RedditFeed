//
//  RedditModels.swift
//  RedditFeed
//
//  Created by F K on 22/01/2022.
//

import Foundation

struct RedditResponse: Codable {
    let data: RedditResultsPage?
}

struct RedditResultsPage: Codable {
    let after: String?
    let before: String?
    let dist: Int
    let children: [RedditResult]
}

struct RedditResult: Codable {
    let kind: String
    let data: RedditPost
}

struct RedditPost: Codable {
    let id: String
    let subreddit: String
    let created: Double
    let domain: String
    let url: String
    let thumbnail: String
    let thumbnail_height: Int?
    let title: String
    let selftext: String
    let is_video: Bool
    let media: RedditMedia?
}

struct RedditMedia: Codable {
    let reddit_video: RedditVideo?
}

struct RedditVideo: Codable {
    let fallback_url: String
}
