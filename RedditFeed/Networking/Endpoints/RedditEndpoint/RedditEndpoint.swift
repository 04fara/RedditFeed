//
//  RedditEndpoint.swift
//  RedditFeed
//
//  Created by Farid Kopzhassarov on 22/01/2022.
//

import Foundation

enum RedditEndpoint: Endpoint {
    enum RedditSortOptions {
        case hot
        case new
        case top
        case rising
    }

    case getSubredditMedia(subreddit: String, sort: RedditSortOptions, after: String? = nil)

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
        case .getSubredditMedia(let subreddit, let sort, _):
            return "/r/\(subreddit)/\(sort).json"
        }
    }

    var parameters: [URLQueryItem] {
        switch self {
        case .getSubredditMedia(_, _, let after):
            var parameters: [URLQueryItem] = [.init(name: "limit", value: "30")]
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
