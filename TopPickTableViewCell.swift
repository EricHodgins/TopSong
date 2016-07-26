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
    @IBOutlet weak var changeButton: UIButton!
    
    @IBOutlet weak var songTitleLeadingMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var artistTitleLeadingMarginConstraint: NSLayoutConstraint!
    
    var topPickIndexPath: NSIndexPath?
    
    weak var delegate: SongChanging?
    
    override func awakeFromNib() {
//        selectionStyle = .None
    }

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
