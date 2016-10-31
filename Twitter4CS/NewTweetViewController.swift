//
//  NewTweetViewController.swift
//  Twitter4CS
//
//  Created by Enta'ard on 10/28/16.
//  Copyright © 2016 Enta'ard. All rights reserved.
//

import UIKit
import AFNetworking

protocol NewTweetViewControllerDelegate {
    
    func newTweetViewController(newTweetViewController: NewTweetViewController, newTweetText text: String, tweetId: Int?)
    
}

class NewTweetViewController: UIViewController {
    
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var characterCounter: UILabel!
    
    var delegate: NewTweetViewControllerDelegate?
    
    fileprivate let maxCharacterCount = 140
    fileprivate var characterCountDown = 140
    fileprivate var currentMaxText = ""
    var replyToTweetId: Int?
    var replyToScreenname: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews()
    }
    
    @IBAction func onBack(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTweet(_ sender: UIBarButtonItem) {
        textView.resignFirstResponder()
        delegate?.newTweetViewController(newTweetViewController: self, newTweetText: textView.text, tweetId: replyToTweetId)
        dismiss(animated: true, completion: nil)
    }
    
    private func initViews() {
        textView.delegate = self
        if replyToScreenname != nil {
            textView.text = "@\(replyToScreenname!) "
            characterCounter.text = "\(maxCharacterCount - textView.text.characters.count)"
        } else {
            textView.text = ""
            characterCounter.text = "\(maxCharacterCount)"
        }
        textView.becomeFirstResponder()
        
        let user = User.loadUser()
        if let profileURL = user?.profileURL {
            profileImgView.setImageWith(profileURL)
        }
        fullnameLabel.text = user?.name
        screennameLabel.text = user?.screenname
        
        TweetViewController.initNavigationBar(of: navigationController!, and: navigationItem, withTitle: "Tweet")
    }
    
}

extension NewTweetViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text
        let characterCount = (text?.characters.count)!
        
        guard characterCount <= maxCharacterCount else {
            textView.text = currentMaxText
            return
        }
        
        if characterCount == maxCharacterCount {
            currentMaxText = text!
        }
        
        characterCountDown = maxCharacterCount - characterCount
        characterCounter.text = "\(characterCountDown)"
        
        if characterCountDown <= 70 && characterCountDown > 10 {
            characterCounter.textColor = UIColor.orange
        } else if characterCountDown <= 10 {
            characterCounter.textColor = UIColor.red
        } else {
            characterCounter.textColor = UIColor(red: 185/255, green: 185/255, blue: 182/255, alpha: 1)
        }
    }
    
}
