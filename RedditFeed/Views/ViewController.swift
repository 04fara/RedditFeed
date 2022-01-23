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

    private var posts: [RedditPost] = []
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

        view.addSubview(collectionView)
        setupCollectionView()

        fetchRedditPosts()
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
        return posts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let post = posts[indexPath.row]
        let cellType: String
        switch post.type {
        case .video:
            cellType = String(describing: RedditVideoCollectionViewCell.self)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType, for: indexPath) as! RedditVideoCollectionViewCell
            cell.setupPost(post)

            return cell
        case .image:
            cellType = String(describing: RedditImageCollectionViewCell.self)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType, for: indexPath) as! RedditImageCollectionViewCell
            cell.setupPost(post)

            return cell
        default:
            return .init()
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == posts.count - 1 {
            fetchRedditPosts()
        }
    }
}

extension ViewController: CustomFlowLayoutDelegate {
  func collectionView(
    _ collectionView: UICollectionView,
    scaleRatioForItemAtIndexPath indexPath:IndexPath) -> CGFloat {
        guard let height = posts[indexPath.row].mediaHeight,
              let width = posts[indexPath.row].mediaWidth
        else { return .zero }

        return CGFloat(height) / CGFloat(width)
  }
}

extension ViewController {
    private func setupCollectionView() {
        if let layout = collectionView.collectionViewLayout as? CustomFlowLayout {
            layout.delegate = self
        }

        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(RedditImageCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: RedditImageCollectionViewCell.self))
        collectionView.register(RedditVideoCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: RedditVideoCollectionViewCell.self))
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    private func fetchRedditPosts() {
        NetworkService.request(endpoint: RedditEndpoint.getSubredditMedia(subreddit: "GlobalOffensive", sort: .top, after: lastPostKindId)) { [weak self] (result: Result<RedditResponse, Error>) in
            switch result {
            case .success(let response):
                let filteredResponse = response.data?.children.filter { $0.data.type.isMedia }
                if let filteredResponse = filteredResponse {
                    self?.posts.append(contentsOf: filteredResponse.compactMap { $0.data })
                    self?.lastPostKind = filteredResponse.last?.kind
                    self?.lastPostId = filteredResponse.last?.data.id
                    self?.collectionView.reloadData()
                } else {
                    print("response is unvalid")
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
