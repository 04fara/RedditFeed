//
//  ViewController.swift
//  RedditFeed
//
//  Created by Farid Kopzhassarov on 22/01/2022.
//

import UIKit

class ViewController: UIViewController {
    private var collectionView: UICollectionView = {
        let layout: CustomFlowLayout = .init()
        let collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        return collectionView
    }()

    private var posts: [RedditPost]?
    private var lastPostKind: String?
    private var lastPostId: String?
    private var lastPostKindId: String? {
        guard let lastPostKind = lastPostKind,
              let lastPostId = lastPostId
        else {
            return nil
        }

        return "\(lastPostKind)_\(lastPostId)"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let layout = collectionView.collectionViewLayout as? CustomFlowLayout {
            layout.delegate = self
        }

        NetworkService.request(endpoint: RedditEndpoint.getSubredditMedia(subreddit: "GlobalOffensive", after: lastPostKindId)) { [weak self] (result: Result<RedditResponse, Error>) in
            switch result {
            case .success(let response):
                let filteredResponse = response.data?.children.filter { $0.data.hasMedia }
                self?.posts = filteredResponse?.compactMap { $0.data }
                self?.lastPostKind = filteredResponse?.last?.kind
                self?.lastPostId = filteredResponse?.last?.data.id
                self?.collectionView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }

        view.addSubview(collectionView)

        collectionView.register(RedditImageCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: RedditImageCollectionViewCell.self))
        collectionView.register(RedditVideoCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: RedditVideoCollectionViewCell.self))
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //collectionView.deselectItem(at: indexPath, animated: true)
        //print(posts?[indexPath.item])
        if let cell = collectionView.cellForItem(at: indexPath) as? RedditVideoCollectionViewCell {
            if cell.queuePlayer?.rate != 0 {
                cell.queuePlayer?.pause()
            } else {
                cell.queuePlayer?.play()
            }
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let post = posts?[indexPath.row],
           post.hasMedia {
            if post.isVideo {
                let postCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: RedditVideoCollectionViewCell.self), for: indexPath) as! RedditVideoCollectionViewCell
                postCollectionViewCell.setupPost(post)

                return postCollectionViewCell
            } else {
                let postCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: RedditImageCollectionViewCell.self), for: indexPath) as! RedditImageCollectionViewCell
                postCollectionViewCell.setupPost(post)

            	return postCollectionViewCell
            }
        }

        return .init()
    }
}

extension ViewController: CustomFlowLayoutDelegate {
  func collectionView(
    _ collectionView: UICollectionView,
    scaleRatioForItemAtIndexPath indexPath:IndexPath) -> CGFloat {
        guard let posts = posts,
              let height = posts[indexPath.item].mediaHeight,
              let width = posts[indexPath.item].mediaWidth
        else { return .zero }

        return CGFloat(height) / CGFloat(width)
  }
}
