//
//  NetworkService.swift
//  RedditFeed
//
//  Created by Farid Kopzhassarov on 24/01/2022.
//

import Foundation

protocol NetworkService {
    @discardableResult
    func request<T: Decodable>(endpoint: Endpoint, completion: @escaping (Result<T, Error>) -> Void) -> URLSessionDataTask?

    @discardableResult
    func request(url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionDataTask?
}
