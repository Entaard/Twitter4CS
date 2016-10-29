//
//  DetailViewController.swift
//  Twitter4CS
//
//  Created by Enta'ard on 10/29/16.
//  Copyright © 2016 Enta'ard. All rights reserved.
//

import UIKit
import AFNetworking

@objc protocol DetailViewControllerDelegate {
    
    @objc func detailViewController(detailViewController: DetailViewController, onBackTo indexPath: IndexPath)
    
}

class DetailViewController: UIViewController {

    let imgHeight: CGFloat = 200
    let twitterClient = TwitterClient.shared
    
    @IBOutlet weak var tableView: UITableView!
    
    var tweet: Tweet?
    var delegate: DetailViewControllerDelegate?
    var selectingIndexPath: IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 170
        
        tableView.reloadData()
    }

    @IBAction func onBack(_ sender: UIBarButtonItem) {
        delegate?.detailViewController(detailViewController: self, onBackTo: selectingIndexPath)
        dismiss(animated: true, completion: nil)
    }

}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        switch section {
        case 0:
            let imgCell = tableView.dequeueReusableCell(withIdentifier: TweetImageCell.tweetImageCellIdentifier) as! TweetImageCell
            
            guard let tweetImgURL = tweet?.mediaImgURL else {
                return UITableViewCell()
            }
            
            imgCell.tweetImgView.setImageWith(tweetImgURL)
            
            return imgCell
        case 1:
            let tweetCell = tableView.dequeueReusableCell(withIdentifier: TweetCell.tweetCellIdentifier) as! TweetCell
            tweetCell.delegate = self
            tweetCell.tweet = tweet
            
            tweetCell.favoriteCountLabel.text = "\((tweet?.favoritesCount)!)"
            tweetCell.retweetCountLabel.text = "\((tweet?.retweetCount)!)"
            
            let isFavourite = tweet?.isFavourite
            TweetCell.setState(ofFavourButton: tweetCell.favourBtn, withFavouriteValue: isFavourite!)
            
            return tweetCell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        switch section {
        case 0:
            guard tweet?.mediaImgURL != nil else {
                return 0
            }
            return 200
        case 1:
            return UITableViewAutomaticDimension
        default:
            return 0
        }
    }
    
}

extension DetailViewController: TweetCellDelegate {
    
    func tweetCell(tweetCell: TweetCell, onFavour favourBtn: UIButton) {
        let tweet = tweetCell.tweet!
        let willBeFavourite = !(tweet.isFavourite)
        let tweetId = tweet.id
        
        twitterClient?.setFavour(tweetId: tweetId, isFavourite: willBeFavourite, success: {
            tweet.isFavourite = willBeFavourite
            
            let favouritesCount = tweet.favoritesCount
            if willBeFavourite {
                tweet.favoritesCount = favouritesCount + 1
            } else if favouritesCount > 0 {
                tweet.favoritesCount = favouritesCount - 1
            }
            
            let indexPath = self.tableView.indexPath(for: tweetCell)
            self.tableView.reloadSections(IndexSet(integer: (indexPath?.section)!), with: .none)
        }, failure: { (error: Error) in
            print("OnFavour error: \(error.localizedDescription)")
        })
    }
    
    func tweetCell(tweetCell: TweetCell, onReplyTo screenname: String, withTweetId tweetId: Int) {
        
    }
    
    func tweetCell(tweetCell: TweetCell, onRetweetTo tweet: Tweet) {
        
    }
    
}
