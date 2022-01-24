//
//  MockNetworkService.swift
//  RedditFeed
//
//  Created by Farid Kopzhassarov on 24/01/2022.
//

import Foundation

class MockNetworkService: NetworkService {
    private let mockData: Data = .init("""
        {
            "data": {
                "after": "after",
                "before": "before",
                "dist": 10,
                "children": [
                    {
                        "kind": "test",
                        "data": {
                            "id": "bwbb1",
                            "subreddit": "subreddit2",
                            "created": 123.0,
                            "domain": "www.google.com",
                            "url": "https://via.placeholder.com/150",
                            "title": "title",
                            "selftext": "selftext",
                            "is_video": false,
                            "preview": {
                                "images": [
                                    {
                                        "source": {
                                            "url": "https://external-preview.redd.it/iHNTzqRCgEFt-uWsYdovcDnyblpoYvMyxZlRUbCOEh4.png?format=pjpg&auto=webp&s=e69b6434b6e5ef7176e1a43a6f3a812a07f3a3b5",
                                            "height": 1080,
                                            "width": 1920
                                        }
                                    }
                                ]
                            }
                        }
                    },
                ]
            }
        }
    """.utf8)

    @discardableResult
    func request<T: Decodable>(endpoint: Endpoint, completion: @escaping (Result<T, Error>) -> Void) -> URLSessionDataTask? {
        if let response = try? JSONDecoder().decode(T.self, from: mockData) {
            DispatchQueue.main.async {
                completion(.success(response))
            }
        }

        return nil
    }

    @discardableResult
    func request(url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionDataTask? {
        completion(.success(mockData))

        return nil
    }
}
