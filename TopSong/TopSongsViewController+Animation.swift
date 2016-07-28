//
//  TopSongsViewController+Animation.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-07-26.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit
import MediaPlayer

extension TopSongsViewController {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TopSongTableViewCell
        currentAnimatingCell = cell
        let song = friendsArray[indexPath.section].topSongs![indexPath.row]
        
        guard song.mediaItem != nil else {
            return
        }
        
        if musicPlayer.nowPlayingItem == song.mediaItem! {
            musicPlayer.stop()
            stopSoundBarAnimation(cell)
            return
        }
        
        if song.isSongPlayable {
            animateArtistTitleLabels(cell)
            activateSoundBars(cell)
            
            let mediaColletion = MPMediaItemCollection(items: [song.mediaItem!])
            musicPlayer.setQueueWithItemCollection(mediaColletion)
            musicPlayer.repeatMode = .None
            musicPlayer.play()
        }
    }
    
    func animateArtistTitleLabels(cell: TopSongTableViewCell) {
        cell.contentView.layoutIfNeeded()
        UIView.animateWithDuration(0.25) { 
            cell.leadingArtistConstraint.constant = 45
            cell.leadingTitleConstraint.constant = 45
            cell.leftBarView.alpha = 1.0
            cell.middleBarView.alpha = 1.0
            cell.rightBarView.alpha = 1.0
            cell.contentView.layoutIfNeeded()
        }
    }
    
    func activateSoundBars(cell: TopSongTableViewCell) {
        let soundBarViews = [cell.leftBarView, cell.middleBarView, cell.rightBarView]
        let randomDuration = Double(randomNumberBetween(0.2, y: 0.5))
        
        cell.contentView.layoutIfNeeded()
        for soundBar in soundBarViews {
        UIView.animateWithDuration(randomDuration, delay: 0, options: [.Repeat, .Autoreverse, .CurveEaseOut], animations: { 
                soundBar.layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
                let yRandomScale = self.randomNumberBetween(0.1, y: 0.5)
                soundBar.transform = CGAffineTransformMakeScale(1, yRandomScale)
                cell.contentView.layoutIfNeeded()
            }, completion: nil)
            
        }
    }
    
    func stopSoundBarAnimation(cell: TopSongTableViewCell) {
        cell.contentView.layoutIfNeeded()
        UIView.animateWithDuration(0.25) { 
            cell.leadingTitleConstraint.constant = 8
            cell.leadingArtistConstraint.constant = 8
            cell.layoutIfNeeded()
        }
        
        cell.leftBarView.alpha = 0
        cell.middleBarView.alpha = 0
        cell.rightBarView.alpha = 0
        
        cell.leftBarView.transform = CGAffineTransformIdentity
        cell.middleBarView.transform = CGAffineTransformIdentity
        cell.rightBarView.transform = CGAffineTransformIdentity
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TopSongTableViewCell
        stopSoundBarAnimation(cell)
        currentAnimatingCell = nil
    }
    
    
    //HELPER:
    func randomNumberBetween(x: CGFloat, y: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(x - y) + min(x, y)
    }
}



