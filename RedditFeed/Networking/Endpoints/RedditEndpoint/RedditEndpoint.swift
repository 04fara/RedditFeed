//
//  RedditEndpoint.swift
//  RedditFeed
//
//  Created by F K on 22/01/2022.
//

import Foundation

enum RedditEndpoint: Endpoint {
    case getSubredditMedia(subreddit: String, after: String? = nil)

    var scheme: String {
        switch self {
        default:
            return "https"
        }
    }

    var baseURL: String {
        switch self {
        default:
            return "www.reddit.com"
        }
    }

    var path: String {
        switch self {
        case .getSubredditMedia(let subreddit, _):
            return "/r/\(subreddit)/new.json"
        }
    }

    var parameters: [URLQueryItem] {
        switch self {
        case .getSubredditMedia(_, let after):
            var parameters: [URLQueryItem] = [.init(name: "limit", value: "10")]
            if let after = after {
                parameters.append(.init(name: "after", value: after))
            }

            return parameters
        }
    }

    var method: String {
        switch self {
        case .getSubredditMedia:
            return "GET"
        }
    }
}
