//
//  FriendTableViewCell.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-06-25.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit

class FriendTableViewCell: UITableViewCell {
    
    @IBOutlet weak var friendProfileImageVIew: UIImageView!
    @IBOutlet weak var friendNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
