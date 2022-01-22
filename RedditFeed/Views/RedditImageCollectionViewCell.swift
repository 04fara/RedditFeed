//
//  RedditImageCollectionViewCell.swift
//  RedditFeed
//
//  Created by Farid Kopzhassarov on 23/01/2022.
//

import UIKit

class RedditImageCollectionViewCell: UICollectionViewCell {
    var dataTask: URLSessionDataTask? = nil

    let imageView: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .secondarySystemBackground
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        return imageView
    }()

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        dataTask?.cancel()
        dataTask = nil
    }
}

extension RedditImageCollectionViewCell {
    func setupPost(_ post: RedditPost) {
        if let url = post.mediaURL {
            dataTask = NetworkService.fetchImage(from: url) { [weak self] result in
                switch result {
                case .success(let image):
                    DispatchQueue.main.async {
                        self?.imageView.image = image
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }

    private func setupView() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 16
        clipsToBounds = true
        contentView.backgroundColor = .secondarySystemBackground

        contentView.addSubview(imageView)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        ])
    }
}
