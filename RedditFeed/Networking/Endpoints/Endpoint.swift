//
//  Endpoint.swift
//  RedditFeed
//
//  Created by F K on 22/01/2022.
//

import Foundation

protocol Endpoint {
    var scheme: String { get }

    var baseURL: String { get }

    var path: String { get }

    var parameters: [URLQueryItem] { get }

    var method: String { get }
}
