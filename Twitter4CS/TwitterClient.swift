//
//  TwitterClient.swift
//  Twitter4CS
//
//  Created by Enta'ard on 10/25/16.
//  Copyright © 2016 Enta'ard. All rights reserved.
//

import Foundation
import BDBOAuth1Manager

let sinceBeginingId: NSInteger = -1

private let appURL = "twitter4CS://oath"
private let consumerKey = "BtrADY1y8syoRKMPXjew6ZGAm"
private let consumerSecret = "nm998DnUoubS3yZQAxgEMTMaLdqNXhmatCQGaV1ZqQJETdvw2G"
private let baseTwitterURL = "https://api.twitter.com"
private let requestTokenPath = "oauth/request_token"
private let authorizePath = "oauth/authorize?oauth_token="
private let accessTokenPath = "oauth/access_token"
private let homeTimelinePath = "1.1/statuses/home_timeline.json"
private let verifyCredentialPath = "1.1/account/verify_credentials.json"
private let favouriteCreatePath = "1.1/favorites/create.json"
private let favouriteDestroyPath = "1.1/favorites/destroy.json"
private let updateStatusPath = "1.1/statuses/update.json?status="
private let retweetPath = "1.1/statuses/retweet/:id.json"

class TwitterClient: BDBOAuth1SessionManager {
    
    static let userDidLogoutNotification = "UserDidLogout"
    static let shared = TwitterClient(baseURL: URL(string: baseTwitterURL), consumerKey: consumerKey, consumerSecret: consumerSecret)
    
    func homeTimeline(sinceId: Int, success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        let parameters: [String: Int]?
        if sinceId == sinceBeginingId {
            parameters = nil
        } else {
            parameters = ["since_id": sinceId]
        }
        get(homeTimelinePath, parameters: parameters, success: { (task, response) in
            let tweetDictionaries = response as! [NSDictionary]
            for dictionary in tweetDictionaries {
                print("dictionary: \(dictionary)")
            }
            let tweets = Tweet.makeTweets(fromTweetDictionaries: tweetDictionaries)
            success(tweets)
            }, failure: { (task, error) in
                failure(error)
        })
    }
    
    func currentAccount(success: @escaping (User) -> (), failure: @escaping (Error) -> ()) {
        get(verifyCredentialPath, parameters: nil, success: { (task, response) in
            let userDictionary = response as! NSDictionary
            let accessToken = self.requestSerializer.accessToken
            let user = User(fromUserDictionary: userDictionary, withAccessToken: accessToken)
            
            success(user)
            
            }, failure: { (task, error) in
                print(error.localizedDescription)
                failure(error)
        })
    }
    
    var loginSuccess: (() -> ())?
    var loginFailure: ((Error) -> ())?
    
    func login(success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        loginSuccess = success
        loginFailure = failure
        
        deauthorize()
        
        fetchRequestToken(withPath: requestTokenPath, method: "POST", callbackURL: URL(string: appURL), scope: nil, success: { (requestCredential) in
            let authToken: String = requestCredential!.token
            let accessUrl = URL(string: "\(baseTwitterURL)/\(authorizePath + authToken)")
            UIApplication.shared.open(accessUrl!, options: ["": ""], completionHandler: nil)
            }, failure: { (error) in
                print("FetchRequestToken error: \(error?.localizedDescription)")
                self.loginFailure?(error!)
        })
    }
    
    func logout() {
        User.save(user: nil)
        deauthorize()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TwitterClient.userDidLogoutNotification), object: nil)
    }
    
    func handleOpenURL(url: URL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        
        fetchAccessToken(withPath: accessTokenPath, method: "POST", requestToken: requestToken, success: { (accessCredential) in
            self.requestSerializer.saveAccessToken(accessCredential)
            self.currentAccount(success: { (user: User) in
                User.save(user: user)
                self.loginSuccess?()
                }, failure: { (error: Error) in
                    self.loginFailure?(error)
            })
            }, failure: { (error) in
                print("FetchAccessToken error: \(error?.localizedDescription)")
                self.loginFailure?(error!)
        })
    }
    
    func setFavour(tweetId id: Int!, isFavourite: Bool, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        let parameters: [String: Int] = ["id": id]
        
        var favouritePath = ""
        if isFavourite {
            favouritePath = favouriteCreatePath
        } else {
            favouritePath = favouriteDestroyPath
        }
        
        post(favouritePath, parameters: parameters, success: { (task, response) in
            success()
        }) { (task, error: Error) in
                failure(error)
        }
    }
    
    func updateStatus(text: String, replyTo tweetId: Int?, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        let updatePath = updateStatusPath + encodedText!
        var parameters = [String: Int]()
        if tweetId != nil {
            parameters["in_reply_to_status_id"] = tweetId
        }
            
        post(updatePath, parameters: parameters, success: { (task, response) in
            let tweetDictionary = response as! NSDictionary
            let tweet = Tweet(fromTweetDictionary: tweetDictionary)
            success(tweet)
        }, failure: { (task, error: Error) in
//            print("error: \(error.localizedDescription)")
            failure(error)
        })
    }
    
    func retweet(tweetId id: Int!, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        let retweetCallPath = retweetPath.replacingOccurrences(of: ":id", with: "\(id!)")
        post(retweetCallPath, parameters: nil, success: { (task, response) in
            let tweetDictionary = response as! NSDictionary
            let tweet = Tweet(fromTweetDictionary: tweetDictionary)
            success(tweet)
        }, failure: { (task, error) in
            failure(error)
        })
    }
    
}
