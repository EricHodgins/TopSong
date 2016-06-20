//
//  TopSongTableViewCell.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-06-18.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit

class TopSongTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var rank: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
