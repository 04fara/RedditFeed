//
//  ViewController.swift
//  RedditFeed
//
//  Created by Farid Kopzhassarov on 22/01/2022.
//

import UIKit

class ViewController: UIViewController {
    private var subredditsCollectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = .init()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        return collectionView
    }()

    private var postsCollectionView: UICollectionView = {
        let layout: CustomFlowLayout = .init()
        let collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        return collectionView
    }()

    private var subreddits: [String] = ["ios", "swift", "GlobalOffensive"]
    private var posts: [String: [RedditPost]] = [:]
    private lazy var subredditsDataSource: SubredditsDataSource = makeSubredditsDataSource()
    private lazy var postsDataSource: PostsDataSource = makePostsDataSource()

    private var selectedSubreddit: String?
    private var lastPostKind: [String: String] = [:]
    private var lastPostId: [String: String] = [:]
    private var lastPostKindId: String? {
        guard let selectedSubreddit = selectedSubreddit,
              let lastPostKind = lastPostKind[selectedSubreddit],
              let lastPostId = lastPostId[selectedSubreddit]
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

        selectedSubreddit = !subreddits.isEmpty ? subreddits[0] : nil

        view.addSubview(subredditsCollectionView)
        setupSubredditsCollectionView()

        view.addSubview(postsCollectionView)
        setupPostsCollectionView()

        applySubredditsSnapshot()
        applyPostsSnapshot(subreddit: selectedSubreddit, animatingDifferences: false)

        fetchRedditPosts(subreddit: selectedSubreddit)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        NSLayoutConstraint.activate([
            subredditsCollectionView.heightAnchor.constraint(equalToConstant: 40),
            subredditsCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            subredditsCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            subredditsCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),

            postsCollectionView.topAnchor.constraint(equalTo: subredditsCollectionView.bottomAnchor, constant: 8),
            postsCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            postsCollectionView.leadingAnchor.constraint(equalTo: subredditsCollectionView.leadingAnchor),
            postsCollectionView.trailingAnchor.constraint(equalTo: subredditsCollectionView.trailingAnchor)
        ])
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if collectionView == postsCollectionView,
           let cell = collectionView.cellForItem(at: indexPath) as? RedditVideoCollectionViewCell {
            if cell.queuePlayer?.rate != 0 {
                cell.queuePlayer?.pause()
            } else {
                cell.queuePlayer?.play()
            }
        } else if let cell = collectionView.cellForItem(at: indexPath) as? SubredditTitleCollectionViewCell {
            postsCollectionView.setContentOffset(.zero, animated: true)
            selectedSubreddit = cell.label.text
            applyPostsSnapshot(subreddit: selectedSubreddit)
            if posts[selectedSubreddit!] == nil {
                fetchRedditPosts(subreddit: selectedSubreddit!)
            } else {
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == postsCollectionView,
           let selectedSubreddit = selectedSubreddit,
           let count = posts[selectedSubreddit]?.count,
           indexPath.row == count - 1 {
            fetchRedditPosts(subreddit: selectedSubreddit)
        }
    }
}

extension ViewController {
    typealias PostsDataSource = UICollectionViewDiffableDataSource<PostsSection, RedditPost>
    typealias PostsSnapshot = NSDiffableDataSourceSnapshot<PostsSection, RedditPost>

    enum PostsSection {
        case feed
    }

    private func makePostsDataSource() -> PostsDataSource {
      let dataSource = PostsDataSource(collectionView: postsCollectionView, cellProvider: { (collectionView, indexPath, post) -> UICollectionViewCell? in
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

    func applyPostsSnapshot(subreddit: String?, animatingDifferences: Bool = true) {
        var snapshot: PostsSnapshot = .init()
        snapshot.appendSections([.feed])
        snapshot.appendItems(posts[subreddit ?? ""] ?? [])

        postsDataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

extension ViewController {
    typealias SubredditsDataSource = UICollectionViewDiffableDataSource<SubredditsSection, String>
    typealias SubredditsSnapshot = NSDiffableDataSourceSnapshot<SubredditsSection, String>

    enum SubredditsSection {
        case main
    }

    private func makeSubredditsDataSource() -> SubredditsDataSource {
      let dataSource = SubredditsDataSource(collectionView: subredditsCollectionView, cellProvider: { (collectionView, indexPath, title) -> UICollectionViewCell? in
          let cellType = String(describing: SubredditTitleCollectionViewCell.self)
          let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType, for: indexPath) as? SubredditTitleCollectionViewCell
          cell?.setupTitle(title)

          return cell
      })

      return dataSource
    }

    func applySubredditsSnapshot(animatingDifferences: Bool = true) {
        var snapshot: SubredditsSnapshot = .init()
        snapshot.appendSections([.main])
        snapshot.appendItems(subreddits)

        subredditsDataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

extension ViewController: CustomFlowLayoutDelegate {
  func collectionView(_ collectionView: UICollectionView, scaleRatioForItemAtIndexPath indexPath:IndexPath) -> CGFloat {
        guard let height = postsDataSource.itemIdentifier(for: indexPath)?.mediaHeight,
              let width = postsDataSource.itemIdentifier(for: indexPath)?.mediaWidth
        else { return 1 }

        return CGFloat(height) / CGFloat(width)
  }
}

extension ViewController {
    private func setupSubredditsCollectionView() {
        subredditsCollectionView.showsHorizontalScrollIndicator = false
        subredditsCollectionView.showsVerticalScrollIndicator = false
        subredditsCollectionView.register(SubredditTitleCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: SubredditTitleCollectionViewCell.self))
        subredditsCollectionView.delegate = self
        subredditsCollectionView.dataSource = subredditsDataSource
    }

    private func setupPostsCollectionView() {
        if let layout = postsCollectionView.collectionViewLayout as? CustomFlowLayout {
            layout.delegate = self
        }

        postsCollectionView.showsHorizontalScrollIndicator = false
        postsCollectionView.showsVerticalScrollIndicator = false
        postsCollectionView.register(RedditImageCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: RedditImageCollectionViewCell.self))
        postsCollectionView.register(RedditVideoCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: RedditVideoCollectionViewCell.self))
        postsCollectionView.delegate = self
        postsCollectionView.dataSource = postsDataSource
    }

    private func fetchRedditPosts(subreddit: String?) {
        guard let subreddit = subreddit else { return }

        networkService.request(endpoint: RedditEndpoint.getSubredditMedia(subreddit: subreddit, sort: .new, after: lastPostKindId)) { [weak self] (result: Result<RedditResponse, Error>) in
            switch result {
            case .success(let response):
                if let resultsPage = response.data {
                    if self?.posts[subreddit] == nil {
                        self?.posts[subreddit] = []
                    }
                    self?.posts[subreddit]!.append(contentsOf: resultsPage.posts.filter { $0.type.isMedia })
                    self?.lastPostKind[subreddit] = resultsPage.children.last?.kind
                    self?.lastPostId[subreddit] = resultsPage.children.last?.data.id

                    if self?.selectedSubreddit == subreddit {
                        self?.applyPostsSnapshot(subreddit: subreddit)
                    }
                } else {
                    print("response is unvalid")
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
