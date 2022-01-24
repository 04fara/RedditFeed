//
//  URLCache+Extensions.swift
//  RedditFeed
//
//  Created by Farid Kopzhassarov on 24/01/2022.
//

import Foundation

extension URLCache {
    static func configSharedCache(directory: String? = Bundle.main.bundleIdentifier, memory: Int = Int(300e6), disk: Int = Int(500e6)) {
        URLCache.shared = {
            let cacheDirectory = (NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] as String).appendingFormat("/\(directory ?? "cache")/")
            return URLCache(memoryCapacity: memory, diskCapacity: disk, diskPath: cacheDirectory)
        }()
    }
}
