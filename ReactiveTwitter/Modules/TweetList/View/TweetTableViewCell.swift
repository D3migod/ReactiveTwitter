//
//  TweetTableViewCell.swift
//  ReactiveTwitter
//
//  Created by Bulat Galiev on 05.03.2018.
//  Copyright © 2018 Bulat. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var message: UITextView!
    
    func update(with tweet: Tweet) {
        name.text = tweet.name
        message.text = tweet.text
        photo.setImage(URL(string: tweet.imageUrl), stopLoadingSignal: prepareForReuseSignal())
        
    }
    
    
}
