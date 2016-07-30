//
//  HitlistTableViewCell.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-07-30.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit

class HitlistTableViewCell: UITableViewCell {
    
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
