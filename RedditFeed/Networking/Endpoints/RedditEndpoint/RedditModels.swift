//
//  RedditModels.swift
//  RedditFeed
//
//  Created by Farid Kopzhassarov on 22/01/2022.
//

import Foundation

private func unescapeURL(_ url: String?) -> String {
    guard let url = url else { return "" }

    let charMap = [
        "&amp;": "&",
        "&lt;": "<",
        "&gt;": ">",
        "&quot;": "\"",
        "&apos;": "'"
    ]
    var unescapedURL = url
    for (escapedChar, unescapedChar) in charMap {
        unescapedURL = unescapedURL.replacingOccurrences(of: escapedChar, with: unescapedChar, options: NSString.CompareOptions.literal, range: nil)
    }

    return unescapedURL
}

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

fileprivate struct RawRedditPost: Decodable {
    struct RedditMedia: Codable {
        let reddit_video: RedditVideo?
    }

    struct RedditVideo: Codable {
        let fallback_url: String
        let height: Int
        let width: Int
    }

    struct RedditPreview: Codable {
        let images: [RedditPreviewImage]
    }

    struct RedditPreviewImage: Codable {
        let source: RedditPreviewSource
    }

    struct RedditPreviewSource: Codable {
        let url: String
        let height: Int
        let width: Int
    }

    let id: String
    let subreddit: String
    let created: Double
    let domain: String
    let url: String
    let title: String
    let selftext: String
    let is_video: Bool
    let media: RedditMedia?
    let preview: RedditPreview?
}

protocol A { }
struct B: A {}

struct RedditPost: Codable {
    let id: String
    let subreddit: String
    let created: Double
    let domain: String
    let url: URL?
    let title: String
    let description: String
    let hasMedia: Bool
    let isVideo: Bool
    let mediaURL: URL?
    let mediaHeight: Int?
    let mediaWidth: Int?

    init(from decoder: Decoder) throws {
        let rawRedditPost: RawRedditPost = try .init(from: decoder)

        id = rawRedditPost.id
        subreddit = rawRedditPost.subreddit
        created = rawRedditPost.created
        domain = rawRedditPost.domain
        url = URL(string: rawRedditPost.url)
        title = rawRedditPost.title
        description = rawRedditPost.selftext
        isVideo = rawRedditPost.is_video
        if isVideo {
            mediaURL = URL(string: unescapeURL(rawRedditPost.media?.reddit_video?.fallback_url))
            mediaHeight = rawRedditPost.media?.reddit_video?.height
            mediaWidth = rawRedditPost.media?.reddit_video?.width
        } else {
            mediaURL = URL(string: unescapeURL(rawRedditPost.preview?.images.first?.source.url))
            mediaHeight = rawRedditPost.preview?.images.first?.source.height
            mediaWidth = rawRedditPost.preview?.images.first?.source.width
        }
        hasMedia = mediaURL != nil
    }
}
