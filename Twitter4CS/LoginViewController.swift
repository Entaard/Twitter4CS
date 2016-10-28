//
//  LoginViewController.swift
//  Twitter4CS
//
//  Created by Enta'ard on 10/25/16.
//  Copyright © 2016 Enta'ard. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class LoginViewController: UIViewController {
    
    static let loginSegueIdentifier = "loginSegue"

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func onLogin(_ sender: UIButton) {    
        TwitterClient.shared?.login(success: {
            print("oh yeah login")
            self.performSegue(withIdentifier: LoginViewController.loginSegueIdentifier, sender: nil)
        }) { (error:Error) in
                print("Error: \(error.localizedDescription)")
        }
    }

}
