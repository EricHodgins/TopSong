//
//  YoutubeTableViewCell.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-08-01.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit

class YoutubeTableViewCell: UITableViewCell {

    @IBOutlet weak var youtubeImageView: UIImageView!
    @IBOutlet weak var songTitle: UILabel!
    
    var sessionTaskToCancelIfCellIsReused: NSURLSessionTask? {
        didSet {
            if let taskToCancel = oldValue {
                taskToCancel.cancel()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
