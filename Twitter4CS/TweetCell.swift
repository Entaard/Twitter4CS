//
//  TweetCell.swift
//  Twitter4CS
//
//  Created by Enta'ard on 10/27/16.
//  Copyright © 2016 Enta'ard. All rights reserved.
//

import UIKit
import AFNetworking

@objc protocol TweetCellDelegate {
    
    @objc optional func tweetCell(tweetCell: TweetCell, onFavour favourBtn: UIButton)
    @objc optional func tweetCell(tweetCell: TweetCell, onReplyTo screenname: String, withTweetId tweetId: Int)
    @objc optional func tweetCell(tweetCell: TweetCell, onRetweetTo tweet: Tweet)
    
}

class TweetCell: UITableViewCell {
    
    static let tweetCellIdentifier = "TweetCell"
    
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetTimeLabel: UILabel!
    @IBOutlet weak var favourBtn: UIButton!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    
    var delegate: TweetCellDelegate?
    
    var tweet: Tweet! {
        didSet {
            if let ownerFullname = tweet.ownerFullname {
                fullnameLabel.text = ownerFullname
                if let ownerScreenname = tweet.ownerScreenname {
                    screennameLabel.text = "@\(ownerScreenname)"
                }
                tweetTextLabel.text = tweet.ownerText ?? ""
                if let ownerImgURL = tweet.ownerImgURL {
                    userImg.setImageWith(ownerImgURL)
                }
            } else {
                fullnameLabel.text = tweet.fullname
                screennameLabel.text = "@\(tweet.screenname)"
                tweetTextLabel.text = tweet.text
                if let userImgURL = tweet.userImgURL {
                    userImg.setImageWith(userImgURL)
                }
            }
            tweetTimeLabel.text = "\(tweet.createDate!)"
        }
    }

    @IBAction func onFavour(_ sender: UIButton) {
        delegate?.tweetCell!(tweetCell: self, onFavour: sender)
    }
    
    @IBAction func onReply(_ sender: UIButton) {
        delegate?.tweetCell!(tweetCell: self, onReplyTo: tweet.screenname, withTweetId: tweet.id)
    }
    
    @IBAction func onRetweet(_ sender: UIButton) {
        delegate?.tweetCell!(tweetCell: self, onRetweetTo: tweet)
    }
    
    class func setState(ofFavourButton favourBtn: UIButton, withFavouriteValue isFavourite: Bool) {
        if isFavourite {
            favourBtn.setImage(UIImage(named: "yellow-star"), for: UIControlState.normal)
            
        } else {
            favourBtn.setImage(UIImage(named: "star"), for: UIControlState.normal)
        }
    }
}
