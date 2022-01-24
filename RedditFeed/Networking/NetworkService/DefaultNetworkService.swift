//
//  NetworkService.swift
//  RedditFeed
//
//  Created by Farid Kopzhassarov on 22/01/2022.
//

import Foundation

class DefaultNetworkService: NetworkService {
    static let shared: DefaultNetworkService = .init()

    @discardableResult
    func request<T: Decodable>(endpoint: Endpoint, completion: @escaping (Result<T, Error>) -> Void) -> URLSessionDataTask? {
        var components: URLComponents = .init()
        components.scheme = endpoint.scheme
        components.host = endpoint.baseURL
        components.path = endpoint.path
        components.queryItems = endpoint.parameters

        guard let url = components.url else { return nil }

        var request: URLRequest = .init(url: url)
        request.httpMethod = endpoint.method

        let session: URLSession = .init(configuration: .default)
        let dataTask = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                print(error.localizedDescription)
                return
            }

            guard let response = response as? HTTPURLResponse,
                  let data = data else { return }

            DispatchQueue.main.async {
                if let responseObject = try? JSONDecoder().decode(T.self, from: data) {
                    completion(.success(responseObject))
                } else {
                    let error: NSError = .init(domain: "", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: "failed to decode the response"])
                    completion(.failure(error))
                }
            }
        }
        dataTask.resume()

        return dataTask
    }

    @discardableResult
    func request(url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionDataTask? {
        let request: URLRequest = .init(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 10)
        let dataTask = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data
            else { return }

            completion(.success(data))
        }
        dataTask.resume()

        return dataTask
    }
}
