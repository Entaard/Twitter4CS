//
//  User.swift
//  Twitter4CS
//
//  Created by Enta'ard on 10/26/16.
//  Copyright © 2016 Enta'ard. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

enum UserProps: String {
    case name, screenname, profileURL, accessToken
}

enum UserDictionaryProps: String {
    case name
    case screenname = "screen_name"
    case profileImg = "profile_image_url_https"
}

class User: NSObject, NSCoding {
    
    static let currentUserIndentifier = "currentUser"
    
    var name: String
    var screenname: String
    var profileURL: URL?
    var accessToken: BDBOAuth1Credential?
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: UserProps.name.rawValue) as? String ?? ""
        screenname = aDecoder.decodeObject(forKey: UserProps.screenname.rawValue) as? String ?? ""
        profileURL = aDecoder.decodeObject(forKey: UserProps.profileURL.rawValue) as? URL
        accessToken = aDecoder.decodeObject(forKey: UserProps.accessToken.rawValue) as? BDBOAuth1Credential
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: UserProps.name.rawValue)
        aCoder.encode(screenname, forKey: UserProps.screenname.rawValue)
        aCoder.encode(profileURL, forKey: UserProps.profileURL.rawValue)
        aCoder.encode(accessToken, forKey: UserProps.accessToken.rawValue)
    }
    
    init(fromUserDictionary user: NSDictionary, withAccessToken token: BDBOAuth1Credential!) {
        name = (user[UserDictionaryProps.name.rawValue] as? String) ?? ""
        screenname = (user[UserDictionaryProps.screenname.rawValue] as? String) ?? ""
        accessToken = token
        
        let profileImgStr = user[UserDictionaryProps.profileImg.rawValue] as? String
        if let profileImgStr = profileImgStr {
                profileURL = URL(string: profileImgStr)
        }
    }
    
    class func save(user: User?) {
        let defaults = UserDefaults.standard
        
        guard user != nil else {
            defaults.removeObject(forKey: currentUserIndentifier)
            defaults.synchronize()
            return
        }
        
        let saveUser = NSKeyedArchiver.archivedData(withRootObject: user!)
        defaults.set(saveUser, forKey: currentUserIndentifier)
        defaults.synchronize()
    }
    
    class func loadUser() -> User? {
        let defaults = UserDefaults.standard
        guard let data = defaults.object(forKey: currentUserIndentifier) as? Data else {
            return nil
        }
        let user = NSKeyedUnarchiver.unarchiveObject(with: data) as! User
        return user
    }
    
}
