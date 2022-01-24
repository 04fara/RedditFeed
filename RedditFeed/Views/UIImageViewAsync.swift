//
//  UIImage+Extensions.swift
//  RedditFeed
//
//  Created by Farid Kopzhassarov on 24/01/2022.
//

import UIKit

class UIImageViewAsync: UIImageView {
    //static let imageCache: NSCache<NSString, UIImage> = .init()

    final private var imageURL: URL?
    final var dataTask: URLSessionDataTask?

    func loadRemoteImage(from url: URL, placeholder: UIImage? = nil) {
        image = placeholder

        imageURL = url

        //if let cachedImage = UIImageViewAsync.imageCache.object(forKey: url.absoluteString as NSString) {
        //    setImage(cachedImage)
        //    return
        //}

        dataTask = DefaultNetworkService.shared.request(url: url) { [weak self] result in
            switch result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    self?.setImage(image)
                    //UIImageViewAsync.imageCache.setObject(image, forKey: url.absoluteString as NSString)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        dataTask?.resume()
    }

    private func setImage(_ image: UIImage?) {
        DispatchQueue.main.async { [weak self] in
            self?.image = image
        }
    }
}
