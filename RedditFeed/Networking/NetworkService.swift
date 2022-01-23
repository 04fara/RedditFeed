//
//  NetworkService.swift
//  RedditFeed
//
//  Created by Farid Kopzhassarov on 22/01/2022.
//

import Foundation
import UIKit
import AVFoundation

let imageCache: NSCache<NSString, UIImage> = .init()
let videoCache: NSCache<NSString, AVQueuePlayer> = .init()
let looperCache: NSCache<AVQueuePlayer, AVPlayerLooper> = .init()

class NetworkService {
    class func request<T: Decodable>(endpoint: Endpoint, completion: @escaping (Result<T, Error>) -> Void) {
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

    class func fetchImage(from url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) -> URLSessionDataTask? {
        if let image = imageCache.object(forKey: url.absoluteString as NSString) {
            completion(.success(image))
            return nil
        }

        let dataTask = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                print(error.localizedDescription)
                return
            }

            guard let data = data,
                  let image = UIImage(data: data)
            else { return }

            imageCache.setObject(image, forKey: url.absoluteString as NSString)
            completion(.success(image))
        }
        dataTask.resume()

        return dataTask
    }
}
