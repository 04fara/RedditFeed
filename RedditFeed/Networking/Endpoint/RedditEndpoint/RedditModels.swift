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
    charMap.forEach { (key, value) in
        unescapedURL = unescapedURL.replacingOccurrences(of: key, with: value, options: .literal)
    }

    return unescapedURL
}

struct RedditResponse: Decodable {
    let data: RedditResultsPage?
}

struct RedditResultsPage: Decodable {
    let after: String?
    let before: String?
    let dist: Int
    let children: [RedditResult]

    var posts: [RedditPost] {
        return children.compactMap { $0.data }
    }
}

struct RedditResult: Decodable {
    let kind: String
    let data: RedditPost
}

fileprivate struct RawRedditPost: Decodable {
    struct RedditMedia: Decodable {
        let reddit_video: RedditVideo?
    }

    struct RedditVideo: Decodable {
        let fallback_url: String
        let height: Int
        let width: Int
    }

    struct RedditPreview: Decodable {
        let images: [RedditPreviewImage]
    }

    struct RedditPreviewImage: Decodable {
        let source: RedditPreviewSource
    }

    struct RedditPreviewSource: Decodable {
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

struct RedditPost: Decodable, Identifiable {
    let uuid: UUID = .init()

    enum RedditPostType {
        case plain
        case image
        case video

        var isMedia: Bool {
            switch self {
            case .plain:
                return false
            case .image:
                return true
            case .video:
                return true
            }
        }
    }

    let id: String
    let subreddit: String
    let created: Double
    let domain: String
    let url: URL?
    let title: String
    let description: String
    let mediaURL: URL?
    let mediaHeight: Int?
    let mediaWidth: Int?
    let type: RedditPostType

    init(from decoder: Decoder) throws {
        let rawRedditPost: RawRedditPost = try .init(from: decoder)

        id = rawRedditPost.id
        subreddit = rawRedditPost.subreddit
        created = rawRedditPost.created
        domain = rawRedditPost.domain
        url = URL(string: rawRedditPost.url)
        title = rawRedditPost.title
        description = rawRedditPost.selftext
        if let video = rawRedditPost.media?.reddit_video {
            type = .video
            mediaURL = URL(string: unescapeURL(video.fallback_url))
            mediaHeight = video.height
            mediaWidth = video.width
        } else if let preview = rawRedditPost.preview?.images.first {
            type = .image
            mediaURL = URL(string: unescapeURL(preview.source.url))
            mediaHeight = preview.source.height
            mediaWidth = preview.source.width
        } else {
            type = .plain
            mediaURL = nil
            mediaHeight = nil
            mediaWidth = nil
        }
    }
}

extension RedditPost: Hashable {
    func hash(into hasher: inout Hasher) {
      hasher.combine(uuid)
    }

    static func == (lhs: RedditPost, rhs: RedditPost) -> Bool {
      lhs.uuid == rhs.uuid
    }
}
