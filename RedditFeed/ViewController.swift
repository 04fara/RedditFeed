//
//  ViewController.swift
//  RedditFeed
//
//  Created by Farid Kopzhassarov on 22/01/2022.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        NetworkService.request(endpoint: RedditEndpoint.getSubredditMedia(subreddit: "GlobalOffensive")) { (result: Result<RedditResponse, Error>) in
            switch result {
            case .success(let response):
                let filteredResponse = response.data?.children.filter { redditResult in
                    let data = redditResult.data
                    return data.is_video || data.media?.reddit_video != nil || data.domain == "i.redd.it"
                }
                filteredResponse?.forEach {
                    print($0)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
