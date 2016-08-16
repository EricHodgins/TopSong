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
        let topSong = friendsArray[indexPath.section].topSongs![indexPath.row]
        
        let musicPlayerState = MusicManager.sharedInstance.playMusic(topSong)
        
        if musicPlayerState == .Stop {
            animatingCellIndex = nil
            resetCell(cell)
        } else if musicPlayerState == .Play {
            animatingCellIndex = indexPath
            animateTextLabels(cell)
            startSoundBarAnimation(cell)
        }
        
    }
    
    func animateTextLabels(cell: TopSongTableViewCell) {
        cell.contentView.layoutIfNeeded()
        UIView.animateWithDuration(0.5) {
            cell.leftBarView.alpha = 1.0
            cell.middleBarView.alpha = 1.0
            cell.rightBarView.alpha = 1.0
            cell.leadingTitleConstraint.constant = 45
            cell.leadingArtistConstraint.constant = 45
            cell.contentView.layoutIfNeeded()
        }
    }
    
    func startSoundBarAnimation(cell: TopSongTableViewCell) {
        let soundBars = [cell.leftBarView, cell.middleBarView, cell.rightBarView]
        
        for soundBar in soundBars {
            let randomTransformYScale = randomNumberBetween(0.2, y: 0.5)
            animateSoundBar(cell, soundBar: soundBar, animatingCellIndex: animatingCellIndex!, withSize: randomTransformYScale)
            
        }
        
    }
    
    
    func animateSoundBar(cell: TopSongTableViewCell, soundBar: UIView, animatingCellIndex: NSIndexPath, withSize size: CGFloat) {
        let randomTime = Double(randomNumberBetween(0.2, y: 0.5))
        
        cell.contentView.layoutIfNeeded()
        
        UIView.animateWithDuration(randomTime, delay: 0, options: [.CurveEaseIn], animations: {
            
            soundBar.layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
            soundBar.transform = CGAffineTransformMakeScale(1.0, size)
            cell.contentView.layoutIfNeeded()
            
        }) { (finshed) in
            UIView.animateWithDuration(randomTime, delay: 0, options: [.CurveEaseOut], animations: {
                soundBar.transform = CGAffineTransformIdentity
                }, completion: { (finished) in
                    
                    guard self.animatingCellIndex != nil else {
                        self.resetCell(cell)
                        return
                    }
                    
                    if animatingCellIndex == self.animatingCellIndex! {
                        let newCell = self.tableView.cellForRowAtIndexPath(animatingCellIndex) as? TopSongTableViewCell
                        if newCell != nil {
                            self.animateSoundBar(newCell!, soundBar: soundBar, animatingCellIndex: animatingCellIndex, withSize: size)
                        }
                    } else {
                        self.resetCell(cell)
                    }
            })
        }

    }
    
    
    func resetCell(cell: TopSongTableViewCell) {
        
        cell.contentView.layoutIfNeeded()
        UIView.animateWithDuration(0.5) {
            cell.leadingArtistConstraint.constant = 8
            cell.leadingTitleConstraint.constant = 8
            cell.leftBarView.alpha = 0
            cell.middleBarView.alpha = 0
            cell.rightBarView.alpha = 0
            cell.contentView.layoutIfNeeded()
        }
    }
    
    //HELPER:
    func randomNumberBetween(x: CGFloat, y: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(x - y) + min(x, y)
    }
}



