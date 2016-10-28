//
//  Tweet.swift
//  Twitter4CS
//
//  Created by Enta'ard on 10/26/16.
//  Copyright © 2016 Enta'ard. All rights reserved.
//

import UIKit

enum TweetProps: String {
    case fullname = "user.name"
    case screenname = "user.screen_name"
    case userImg = "user.profile_image_url_https"
    case mediaImg = "entities.media.media_url_https"
    case ownerFullname = "quoted_status.user.name"
    case ownerScreenname = "quoted_status.user.screen_name"
    case ownerText = "quoted_status.text"
    case ownerImg = "quoted_status.user.profile_image_url_https"
    case screennameReplyTo = "in_reply_to_screen_name"
    case text, retweet_count, favourites_count, retweeted, created_at, id, favorited
}

class Tweet: NSObject {
    
    var fullname: String
    var screenname: String
    var text: String
    var ownerFullname: String?
    var ownerScreenname: String?
    var ownerText: String?
    var screennameReplyTo: String?
    var retweetCount: Int = 0
    var favoritesCount: Int = 0
    var retweeted: Bool
    var createDate: String?
    var userImgURL: URL?
    var ownerImgURL: URL?
    var mediaImgURL: URL?
    var id: Int!
    var isFavourite: Bool
    
    init(fromTweetDictionary tweet: NSDictionary) {
        id = tweet.value(forKeyPath: TweetProps.id.rawValue) as! Int
        fullname = (tweet.value(forKeyPath: TweetProps.fullname.rawValue) as? String) ?? ""
        screenname = (tweet.value(forKeyPath: TweetProps.screenname.rawValue) as? String) ?? ""
        
        ownerFullname = tweet.value(forKeyPath: TweetProps.ownerFullname.rawValue) as? String
        if ownerFullname != nil {
            ownerScreenname = tweet.value(forKeyPath: TweetProps.ownerScreenname.rawValue) as? String
            ownerText = tweet.value(forKeyPath: TweetProps.ownerText.rawValue) as? String
            
            let ownerImgStr = tweet.value(forKeyPath: TweetProps.ownerImg.rawValue) as? String
            if let ownerImgStr = ownerImgStr {
                ownerImgURL = URL(string: ownerImgStr)
            }
        }
        
        screennameReplyTo = tweet.value(forKeyPath: TweetProps.screennameReplyTo.rawValue) as? String
        text = (tweet[TweetProps.text.rawValue] as? String) ?? ""
        retweetCount = (tweet[TweetProps.retweet_count.rawValue] as? Int) ?? 0
        favoritesCount = (tweet[TweetProps.favourites_count.rawValue] as? Int) ?? 0
        retweeted = (tweet[TweetProps.retweeted.rawValue] as? Bool) ?? false
        
        let timestampStr = tweet[TweetProps.created_at.rawValue] as? String
        createDate = Tweet.calculateTime(withTimeStr: timestampStr)
        
        let userImgStr = tweet.value(forKeyPath: TweetProps.userImg.rawValue) as? String
        if let userImgStr = userImgStr {
            userImgURL = URL(string: userImgStr)
        }
        
        let media = tweet.value(forKeyPath: TweetProps.mediaImg.rawValue) as? NSArray
        if let media = media {
            mediaImgURL = URL(string: media[0] as! String)
        }
        
        isFavourite = tweet.value(forKeyPath: TweetProps.favorited.rawValue) as! Bool
    }
    
    class func makeTweets(fromTweetDictionaries dictionaries: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        for dictionary in dictionaries {
            let tweet = Tweet(fromTweetDictionary: dictionary)
            tweets.append(tweet)
        }
        return tweets
    }
    
    class func calculateTime(withTimeStr timestampStr: String?) -> String! {
        guard timestampStr != nil else {
            return ""
        }
        
        let formatterGet = DateFormatter()
        formatterGet.dateFormat = "EEE MMM d HH:mm:ss Z y"
        let timestamp = formatterGet.date(from: timestampStr!)
        
        guard timestamp != nil else {
            return ""
        }
        
        let secondsOfAMin: Double = 60
        let secondsOfAnHour: Double = 60 * 60
        let secondsOfADay: Double = 24 * secondsOfAnHour
        let timeInterval = -timestamp!.timeIntervalSinceNow
        let formatterDisplay = DateFormatter()
        
        if timeInterval > secondsOfADay {
            formatterDisplay.dateFormat = "MM/dd/yyyy"
            return formatterDisplay.string(from: timestamp!)
        } else if timeInterval > secondsOfAnHour {
            formatterDisplay.dateFormat = "HH"
            return "\(Int(timeInterval/60/60))h ago"
        } else if timeInterval > secondsOfAMin {
            formatterDisplay.dateFormat = "mm"
            return "\(Int(timeInterval/60))min ago"
        } else {
            formatterDisplay.dateFormat = "ss"
            return "\(Int(timeInterval/60))s ago"
        }
    }
    
}
