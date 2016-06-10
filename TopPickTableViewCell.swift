//
//  TopPickTableViewCell.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-06-07.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit

class TopPickTableViewCell: UITableViewCell {

    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    
    var topPickIndexPath: NSIndexPath?
    
    weak var delegate: SongChanging?

    init() {
        super.init(style: .Subtitle, reuseIdentifier: "pickerCell")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @IBAction func changeButtonPressed(sender: AnyObject) {
        delegate?.changingNewTopSongAt(topPickIndexPath!)
    }
}
