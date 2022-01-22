//
//  NetworkService.swift
//  RedditFeed
//
//  Created by F K on 22/01/2022.
//

import Foundation

class NetworkService {
    class func request<T: Codable>(endpoint: Endpoint, completion: @escaping (Result<T, Error>) -> Void) {
        var components: URLComponents = .init()
        components.scheme = endpoint.scheme
        components.host = endpoint.baseURL
        components.path = endpoint.path
        components.queryItems = endpoint.parameters

        guard let url = components.url else { return }

        var urlRequest: URLRequest = .init(url: url)
        urlRequest.httpMethod = endpoint.method

        let session: URLSession = .init(configuration: .default)
        let dataTask = session.dataTask(with: urlRequest) { data, response, error in
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
    }
}
