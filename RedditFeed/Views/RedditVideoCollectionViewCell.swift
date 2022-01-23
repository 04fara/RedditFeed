//
//  RedditVideoCollectionViewCell.swift
//  RedditFeed
//
//  Created by Farid Kopzhassarov on 23/01/2022.
//

import UIKit
import AVKit

class RedditVideoCollectionViewCell: UICollectionViewCell {
    var playerLooper: AVPlayerLooper?
    var queuePlayer: AVQueuePlayer?
    var playerLayer: AVPlayerLayer?

    // TODO: add preview image before video is ready
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
        //setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        queuePlayer?.pause()
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        playerLooper = nil
        queuePlayer = nil
    }
}

extension RedditVideoCollectionViewCell {
    func setupPost(_ post: RedditPost) {
        if let url = post.mediaURL {
            queuePlayer = {
                let newQueuePlayer: AVQueuePlayer
                if let cachedQueuePlayer = videoCache.object(forKey: url.absoluteString as NSString),
                   let cachedPlayerLooper = looperCache.object(forKey: cachedQueuePlayer) {
                    newQueuePlayer = cachedQueuePlayer
                    playerLooper = cachedPlayerLooper
                } else {
                    let playerItem: AVPlayerItem = .init(url: url)
                    newQueuePlayer = .init(playerItem: playerItem)
                    playerLooper = .init(player: newQueuePlayer, templateItem: playerItem)
                    videoCache.setObject(newQueuePlayer, forKey: url.absoluteString as NSString)
                    looperCache.setObject(playerLooper!, forKey: newQueuePlayer)
                }

                return newQueuePlayer
            }()
            playerLayer = {
                let newPlayerLayer: AVPlayerLayer = .init(player: queuePlayer)
                newPlayerLayer.frame = bounds
                newPlayerLayer.videoGravity = .resizeAspectFill
                layer.addSublayer(newPlayerLayer)
                queuePlayer?.play()

                return newPlayerLayer
            }()
        }
    }

    private func setupView() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 16
        clipsToBounds = true
        contentView.backgroundColor = .secondarySystemBackground

        //contentView.addSubview(imageView)
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
