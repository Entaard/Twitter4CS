//
//  TweetImageCell.swift
//  Twitter4CS
//
//  Created by Enta'ard on 10/29/16.
//  Copyright © 2016 Enta'ard. All rights reserved.
//

import UIKit

class TweetImageCell: UITableViewCell {
    
    static let tweetImageCellIdentifier = "TweetImageCell"

    @IBOutlet weak var tweetImgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
