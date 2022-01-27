//
//  RedditFeedTests.swift
//  RedditFeedTests
//
//  Created by Farid Kopzhassarov on 22/01/2022.
//

import XCTest
@testable import RedditFeed

class RedditFeedTests: XCTestCase {
    func testNetworkServiceRequest() throws {
        let mockNetworkService: MockNetworkService = .init()
        mockNetworkService.request(endpoint: RedditEndpoint.getSubredditMedia(subreddit: "GlobalOffensive", sort: .new)) { (result: Result<RedditResponse, Error>) in
            switch result {
            case .success(let response):
                XCTAssertNotNil(response.data)
                let resultsPage = response.data!
                let posts = resultsPage.posts
                XCTAssertEqual(posts.count, 1)
                break
            case .failure(_):
                break
            }
        }
    }
}
