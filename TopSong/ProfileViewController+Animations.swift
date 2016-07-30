//
//  ProfileViewController+Animations.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-07-26.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit
import MediaPlayer

extension ProfileViewController {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let topSongVC = (tabBarController?.viewControllers![1] as! UINavigationController).viewControllers[0] as! TopSongsViewController
        if topSongVC.currentAnimatingCell != nil {
            topSongVC.stopSoundBarAnimation(topSongVC.currentAnimatingCell!)
        }
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TopPickTableViewCell
        currentAnimatingCell = cell
        let song = userTopPicks[indexPath.row]
        
        guard song?.mediaItem != nil else {
            return
        }
        
        //stop music playing when the current song picked is picked again
        if musicPlayer.nowPlayingItem == song!.mediaItem! {
            musicPlayer.stop()
            self.stopSoundBarAnimation(cell)
            return
        }
        
        
        if song?.isSongPlayable == true && song != nil {
            cell.contentView.layoutIfNeeded()
            UIView.animateWithDuration(0.25, animations: {
                cell.artistTitleLeadingMarginConstraint.constant = -45
                cell.songTitleLeadingMarginConstraint.constant = -45
                cell.leftBarView.alpha = 1.0
                cell.middleBarView.alpha = 1.0
                cell.rightBarView.alpha = 1.0
                cell.contentView.layoutIfNeeded()
            })
            
            let mediaCollection = MPMediaItemCollection(items: [song!.mediaItem!])
            musicPlayer.setQueueWithItemCollection(mediaCollection)
            musicPlayer.repeatMode = .None
            musicPlayer.play()
            
            self.animateCellSoundBars(cell)
        }
    }
    
    func animateCellSoundBars(cell: TopPickTableViewCell) {
        
        let soundbarViews = [cell.leftBarView, cell.middleBarView, cell.rightBarView]
        let randomDuration = Double(randomNumberBetween(0.2, y: 0.5))
        
        
        cell.leftBarView.transform = CGAffineTransformIdentity
        cell.middleBarView.transform = CGAffineTransformIdentity
        cell.rightBarView.transform = CGAffineTransformIdentity
        
        cell.contentView.layoutIfNeeded()
        for soundBar in soundbarViews {
            UIView.animateWithDuration(randomDuration, delay: 0, options: [.Repeat, .Autoreverse, .CurveEaseOut], animations: {
                soundBar.layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
                let yRandomScale = self.randomNumberBetween(0.1, y: 0.5)
                soundBar.transform = CGAffineTransformMakeScale(1, yRandomScale)
                cell.contentView.layoutIfNeeded()
                }, completion: nil)
        }
        
    }
    
    func randomNumberBetween(x: CGFloat, y: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(x - y) + min(x, y)
    }
    
    func stopSoundBarAnimation(cell: TopPickTableViewCell) {
        cell.contentView.layoutIfNeeded()
        UIView.animateWithDuration(0.25) {
            cell.artistTitleLeadingMarginConstraint.constant = -8
            cell.songTitleLeadingMarginConstraint.constant = -8
            cell.contentView.layoutIfNeeded()
        }
        
        cell.leftBarView.alpha = 0
        cell.middleBarView.alpha = 0
        cell.rightBarView.alpha = 0
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TopPickTableViewCell
        currentAnimatingCell = nil
        stopSoundBarAnimation(cell)
    }

}








