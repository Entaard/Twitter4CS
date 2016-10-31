//
//  TweetViewController.swift
//  Twitter4CS
//
//  Created by Enta'ard on 10/26/16.
//  Copyright © 2016 Enta'ard. All rights reserved.
//

import UIKit

let twitterBlue = UIColor(red: 0, green: 172/255, blue: 237/255, alpha: 1)

class TweetViewController: UIViewController {
    
    let headerHeight: CGFloat = 15
    let headerPaddingTop: CGFloat = 3
    let twitterClient = TwitterClient.shared
    let refreshControl = UIRefreshControl()
    let newTweetSegueIdentifier = "NewTweetSegue"
    let replyTweetSegueIdentifier = "ReplyTweetSegue"
    let detailSegueIdentifier = "DetailSegue"
    
    @IBOutlet weak var tweetsTable: UITableView!
    @IBOutlet weak var scrollTopBtn: UIButton!
    
    var tweets = [Tweet]()
    var replyToTweetId: Int?
    var replyToScreenname: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews()
        getHomeTimeline()
    }
    
    @IBAction func onLogout(_ sender: UIBarButtonItem) {
        twitterClient?.logout()
    }
    
    @IBAction func onScrollTop(_ sender: UIButton) {
        let indexPathOfFirstRow = IndexPath(row: 0, section: 0)
        tweetsTable.scrollToRow(at: indexPathOfFirstRow, at: .top, animated: true)
        sender.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifier = segue.identifier
        let navigationController = segue.destination as! UINavigationController
        if identifier == newTweetSegueIdentifier || identifier == replyTweetSegueIdentifier {
            let newTweetViewController = navigationController.topViewController as! NewTweetViewController
            
            newTweetViewController.delegate = self
            
            if identifier == replyTweetSegueIdentifier {
                newTweetViewController.replyToTweetId = replyToTweetId
                newTweetViewController.replyToScreenname = replyToScreenname
            }
        } else if identifier == detailSegueIdentifier {
            let detailViewController = navigationController.topViewController as! DetailViewController
            let indexPath = tweetsTable.indexPathForSelectedRow
            let index = indexPath?.section
            detailViewController.tweet = tweets[index!]
            detailViewController.selectingIndexPath = indexPath
            detailViewController.delegate = self
        }
    }
    
//    func appendToTop(newTweet: Tweet) {
//        var newTweets = [newTweet]
//        newTweets.append(contentsOf: tweets)
//        tweets = newTweets
//    }
    
    @objc func getHomeTimeline(sinceId: NSInteger = sinceBeginingId) {
        twitterClient?.homeTimeline(sinceId: sinceId, success: { (tweets: [Tweet]) in
            if sinceId == sinceBeginingId {
                self.tweets = tweets
            } else {
                self.tweets.append(contentsOf: tweets)
            }
            
            for tweet in tweets {
                print(tweet.text)
            }
            
            self.tweetsTable.reloadData()
            self.refreshControl.endRefreshing()
        }, failure: { (error: Error) in
            print("Error: \(error.localizedDescription)")
            self.twitterClient?.logout()
        })
    }
    
    func initViews() {
        scrollTopBtn.isHidden = true
        
        refreshControl.addTarget(self, action: #selector(TweetViewController.getHomeTimeline(sinceId:)), for: UIControlEvents.valueChanged)
        tweetsTable.addSubview(refreshControl)
        
        tweetsTable.dataSource = self
        tweetsTable.delegate = self
        
        tweetsTable.rowHeight = UITableViewAutomaticDimension
        tweetsTable.estimatedRowHeight = 90
        tweetsTable.separatorColor = twitterBlue
        TweetViewController.initNavigationBar(of: navigationController!, and: navigationItem, withTitle: "Home")
    }
    
    static func initNavigationBar(of navigationController: UINavigationController, and navigationItem: UINavigationItem, withTitle title: String?) {
        let navigationBar = navigationController.navigationBar
        navigationBar.barTintColor = twitterBlue
        navigationBar.tintColor = UIColor.white
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationItem.title = title
    }
    
}

extension TweetViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tweetsTable.dequeueReusableCell(withIdentifier: TweetCell.tweetCellIdentifier) as! TweetCell
        cell.delegate = self
        cell.tweet = tweets[indexPath.section]
        
        let isFavourite = cell.tweet.isFavourite
        TweetCell.setState(ofFavourButton: cell.favourBtn, withFavouriteValue: isFavourite)
        
        cell.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let haveScrollTopCellIndex = 19
        let lastCellIndex = tweets.count - 1
        let currentIndex = indexPath.section
        
        scrollTopBtn.isHidden = currentIndex < haveScrollTopCellIndex
        
        if indexPath.section >= lastCellIndex {
            scrollTopBtn.isHidden = false
            let sinceId = tweets[lastCellIndex].id
            getHomeTimeline(sinceId: sinceId!)
            tweetsTable.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let currentTweet = tweets[section]
        let ownerFullname = currentTweet.ownerFullname
        let nameReplyTo = currentTweet.screennameReplyTo
        guard ownerFullname != nil || nameReplyTo != nil else {
            return UIView()
        }
        
        let headerView = UIView(frame: CGRect( x: 0, y: 0, width: tableView.bounds.width, height: headerHeight))
        headerView.backgroundColor = UIColor.clear
        
        // TODO: Auto layout???
        let separator = UIView(frame: CGRect(x: 10, y: 0, width: tableView.bounds.width - 20, height: 0.5))
        separator.backgroundColor = twitterBlue
        
        let headerLabel = UILabel(frame: CGRect(x: 40, y: headerPaddingTop, width: tableView.bounds.width, height: headerHeight))
        headerLabel.font = UIFont.systemFont(ofSize: 11)
        headerLabel.textColor = UIColor(red: 185/255, green: 185/255, blue: 182/255, alpha: 1)
        
        let imgView = UIImageView(frame: CGRect(x: 20, y: headerPaddingTop, width: 12, height: 12))
        if ownerFullname != nil {
            imgView.image = UIImage(named: "retweet")
            headerLabel.text = "\(currentTweet.screenname) retweeted"
        } else {
            imgView.image = UIImage(named: "reply")
            headerLabel.text = "In reply to \(currentTweet.screennameReplyTo!)"
        }
        
        headerView.addSubview(separator)
        headerView.addSubview(imgView)
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let ownerFullname = tweets[section].ownerFullname
        let nameReplyTo = tweets[section].screennameReplyTo
        guard ownerFullname != nil || nameReplyTo != nil else {
            return 0
        }
        return headerHeight
    }
    
}

extension TweetViewController: TweetCellDelegate {
    
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
            
            let indexPath = self.tweetsTable.indexPath(for: tweetCell)
            self.tweetsTable.reloadSections(IndexSet(integer: (indexPath?.section)!), with: .none)
        }, failure: { (error: Error) in
            print("OnFavour error: \(error.localizedDescription)")
        })
    }
    
    func tweetCell(tweetCell: TweetCell, onReplyTo screenname: String, withTweetId tweetId: Int) {
        replyToScreenname = screenname
        replyToTweetId = tweetId
    }
    
    func tweetCell(tweetCell: TweetCell, onRetweetTo tweet: Tweet) {
        twitterClient?.retweet(tweetId: tweet.id, success: { (newRetweet: Tweet) in
            self.tweets.insert(newRetweet, at: 0)
            tweet.retweetCount += 1
            self.tweetsTable.reloadData()
            
        }, failure: { (error: Error) in
            print("Retweet error: \(error.localizedDescription)")
        })
    }
    
}

extension TweetViewController: NewTweetViewControllerDelegate {
    
    func newTweetViewController(newTweetViewController: NewTweetViewController, newTweetText text: String, tweetId: Int?) {
        twitterClient?.updateStatus(text: text, replyTo: tweetId, success: { (tweet) in
            self.tweets.insert(tweet, at: 0)
            
            self.tweetsTable.reloadData()
        }, failure: { (error: Error) in
            print("New Tweet error: \(error.localizedDescription)")
        })
    }
    
}

extension TweetViewController: DetailViewControllerDelegate {
    
    func detailViewController(detailViewController: DetailViewController, onBackTo indexPath: IndexPath) {
        let newRetweet = detailViewController.newRetweet
        let newReplyTweet = detailViewController.newReplyTweet
        
        guard newRetweet == nil && newReplyTweet == nil else {
            if newRetweet != nil {
                tweets.insert(newRetweet!, at: 0)
            }
            if newReplyTweet != nil {
                tweets.insert(newReplyTweet!, at: 0)
            }
            tweetsTable.reloadData()
            return
        }
        
        tweetsTable.reloadRows(at: [indexPath], with: .none)
    }
    
}
