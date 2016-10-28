//
//  AppDelegate.swift
//  Twitter4CS
//
//  Created by Enta'ard on 10/25/16.
//  Copyright © 2016 Enta'ard. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if let currentUser = User.loadUser() {
            print("there is a current user")
            if let accessToken = currentUser.accessToken {
                TwitterClient.shared?.requestSerializer.saveAccessToken(accessToken)
                let myStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
                let homeViewController = myStoryboard.instantiateViewController(withIdentifier: "TweetNavigationController")
                window?.rootViewController = homeViewController
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: TwitterClient.userDidLogoutNotification), object: nil, queue: OperationQueue.main) { (notification: Notification) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginViewController = storyboard.instantiateInitialViewController()
            self.window?.rootViewController = loginViewController
        }
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        TwitterClient.shared?.handleOpenURL(url: url)
        
        return true
    }

}

