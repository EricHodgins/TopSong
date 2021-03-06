//
//  TopSongTableViewCell.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-06-18.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit

class TopSongTableViewCell: MusicTableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!

    @IBOutlet weak var rankingImageView: UIImageView!
    @IBOutlet weak var iphoneNotPlayableImageView: UIImageView!
    
    @IBOutlet weak var leftBarView: UIView!
    @IBOutlet weak var middleBarView: UIView!
    @IBOutlet weak var rightBarView: UIView!
    
    @IBOutlet weak var leadingTitleConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingArtistConstraint: NSLayoutConstraint!
    
    weak var delegate: HitlistMoreButtonProtocol?
    var songIndexPath: NSIndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .None
        leftBarView.alpha = 0
        middleBarView.alpha = 0
        rightBarView.alpha = 0
        iphoneNotPlayableImageView.alpha = 0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        leadingTitleConstraint.constant = 8
        leadingArtistConstraint.constant = 8
        leftBarView.alpha = 0
        middleBarView.alpha = 0
        rightBarView.alpha = 0
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func hitlistButtonPressed(sender: AnyObject) {
        delegate?.hitlistMoreButtonPressed(songIndexPath!)
    }
    
}
