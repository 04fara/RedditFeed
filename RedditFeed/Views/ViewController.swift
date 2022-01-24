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
    private lazy var dataSource: DataSource = makeDataSource()

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

    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        setupCollectionView()
        applySnapshot(animatingDifferences: false)

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

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == posts.count - 1 {
            fetchRedditPosts()
        }
    }
}

extension ViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, RedditPost>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, RedditPost>

    enum Section {
        case feed
    }

    private func makeDataSource() -> DataSource {
      let dataSource = DataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, post) -> UICollectionViewCell? in
          switch post.type {
          case .video:
              let cellType = String(describing: RedditVideoCollectionViewCell.self)
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType, for: indexPath) as? RedditVideoCollectionViewCell
              cell?.setupPost(post)

              return cell
          case .image:
              let cellType = String(describing: RedditImageCollectionViewCell.self)
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType, for: indexPath) as? RedditImageCollectionViewCell
              cell?.setupPost(post)

              return cell
          default:
              let cellType = String(describing: UICollectionViewCell.self)
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType, for: indexPath)

              return cell
          }
      })

      return dataSource
    }

    func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot: Snapshot = .init()
        snapshot.appendSections([.feed])
        snapshot.appendItems(posts)

        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

extension ViewController: CustomFlowLayoutDelegate {
  func collectionView(_ collectionView: UICollectionView, scaleRatioForItemAtIndexPath indexPath:IndexPath) -> CGFloat {
        guard let height = dataSource.itemIdentifier(for: indexPath)?.mediaHeight,
              let width = dataSource.itemIdentifier(for: indexPath)?.mediaWidth
        else { return 1 }

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
        collectionView.dataSource = dataSource
    }

    private func fetchRedditPosts() {
        networkService.request(endpoint: RedditEndpoint.getSubredditMedia(subreddit: "GlobalOffensive", sort: .new, after: lastPostKindId)) { [weak self] (result: Result<RedditResponse, Error>) in
            switch result {
            case .success(let response):
                if let resultsPage = response.data {
                    self?.posts.append(contentsOf: resultsPage.posts.filter { $0.type.isMedia })
                    self?.lastPostKind = resultsPage.children.last?.kind
                    self?.lastPostId = resultsPage.children.last?.data.id
                    self?.applySnapshot()
                } else {
                    print("response is unvalid")
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
